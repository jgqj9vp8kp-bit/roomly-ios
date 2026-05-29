import Foundation

@MainActor
final class SubscriptionViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case processing
        case completed
        case failed(String)
    }

    /// Lifecycle of the App Store product catalog, kept separate from `phase`
    /// (which tracks purchase/restore actions).
    enum ProductsState: Equatable {
        case loading
        case loaded
        case failed
        case unavailable
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var productsState: ProductsState = .loading
    @Published private(set) var offers: [SubscriptionOffer] = []
    @Published private(set) var selectedOfferID: String?
    @Published private(set) var isPremium: Bool {
        didSet {
            if isPremium != oldValue {
                defaults.set(isPremium, forKey: Self.premiumStorageKey)
            }
        }
    }

    let features: [String]

    private let service: SubscriptionService
    private let defaults: UserDefaults
    private static let premiumStorageKey = "isPremiumEntitled"

    init(
        service: SubscriptionService? = nil,
        features: [String] = MockWeatherData.premiumFeatures,
        defaults: UserDefaults = .standard
    ) {
        self.service = service ?? SubscriptionService()
        self.features = features
        self.defaults = defaults
        self.isPremium = defaults.bool(forKey: Self.premiumStorageKey)
    }

    var selectedOffer: SubscriptionOffer? {
        offers.first(where: { $0.id == selectedOfferID })
    }

    var isProcessing: Bool {
        if case .processing = phase { return true }
        return false
    }

    var hasOffers: Bool { !offers.isEmpty }

    func loadOffers() async {
        if offers.isEmpty {
            productsState = .loading
        }

        await service.loadOffers()
        offers = service.offers
        if selectedOfferID == nil {
            selectedOfferID = preferredOffer(in: offers)?.id
        }
        await refreshEntitlements()

        if service.loadFailed {
            productsState = .failed
        } else if offers.isEmpty {
            productsState = .unavailable
        } else {
            productsState = .loaded
        }
    }

    func select(_ offer: SubscriptionOffer) {
        selectedOfferID = offer.id
        phase = .idle
    }

    func continueWithSelectedPlan() async {
        guard let offer = selectedOffer else {
            phase = .failed("Please choose a plan to continue.")
            return
        }

        phase = .processing
        do {
            try await service.purchase(offer)
            await refreshEntitlements()
            phase = .completed
        } catch let error as SubscriptionPurchaseError {
            if case .cancelled = error {
                phase = .idle
            } else {
                phase = .failed(error.localizedDescription)
            }
        } catch {
            AppLogger.subscription.error("Purchase failed: \(error.localizedDescription, privacy: .public)")
            phase = .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        phase = .processing
        do {
            try await service.restore()
            await refreshEntitlements()
            if isPremium {
                phase = .completed
            } else {
                phase = .failed("No active subscription was found to restore.")
            }
        } catch {
            AppLogger.subscription.error("Restore failed: \(error.localizedDescription, privacy: .public)")
            phase = .failed("Restore could not complete. Please try again.")
        }
    }

    func clearError() {
        if case .failed = phase {
            phase = .idle
        }
    }

    private func refreshEntitlements() async {
        await service.refreshEntitlements()
        isPremium = service.status.isActive
    }

    private func preferredOffer(in offers: [SubscriptionOffer]) -> SubscriptionOffer? {
        offers.first(where: { $0.id == RoomlyProductID.yearly.rawValue }) ?? offers.first
    }
}
