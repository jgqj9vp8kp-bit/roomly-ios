import Foundation
import StoreKit

enum RoomlyProductID: String, CaseIterable {
    case weekly = "roomly_premium_weekly"
    case yearly = "roomly_premium_yearly"
}

struct SubscriptionOffer: Identifiable, Equatable {
    let product: Product
    let badge: String?

    var id: String { product.id }
    var title: String { product.displayName }
    var subtitle: String { product.description }
    var displayPrice: String { product.displayPrice }
    var periodTitle: String {
        guard let subscription = product.subscription else { return "" }
        return subscription.subscriptionPeriod.localizedPeriod
    }
}

enum SubscriptionStatus: Equatable {
    case unknown
    case notSubscribed
    case subscribed(expirationDate: Date?)

    var isActive: Bool {
        if case .subscribed = self { return true }
        return false
    }
}

@MainActor
final class SubscriptionService: ObservableObject {
    @Published private(set) var offers: [SubscriptionOffer] = []
    @Published private(set) var status: SubscriptionStatus = .unknown
    @Published private(set) var loadFailed = false

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(transactionResult: update)
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadOffers() async {
        loadFailed = false
        do {
            let products = try await Product.products(for: RoomlyProductID.allCases.map(\.rawValue))
            let sorted = products.sorted { lhs, rhs in
                priority(for: lhs.id) < priority(for: rhs.id)
            }
            offers = sorted.map { product in
                SubscriptionOffer(product: product, badge: badge(for: product.id))
            }
        } catch {
            AppLogger.subscription.error("Failed to load products: \(error.localizedDescription, privacy: .public)")
            offers = []
            loadFailed = true
        }
        await refreshEntitlements()
    }

    func purchase(_ offer: SubscriptionOffer) async throws {
        let result = try await offer.product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshEntitlements()
        case .userCancelled:
            throw SubscriptionPurchaseError.cancelled
        case .pending:
            throw SubscriptionPurchaseError.pending
        @unknown default:
            throw SubscriptionPurchaseError.unknown
        }
    }

    func restore() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var latest: Transaction?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard RoomlyProductID(rawValue: transaction.productID) != nil else { continue }
            if let current = latest {
                if (transaction.expirationDate ?? .distantFuture) > (current.expirationDate ?? .distantFuture) {
                    latest = transaction
                }
            } else {
                latest = transaction
            }
        }

        if let latest {
            status = .subscribed(expirationDate: latest.expirationDate)
        } else {
            status = .notSubscribed
        }
    }

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        switch transactionResult {
        case .verified(let transaction):
            await transaction.finish()
            await refreshEntitlements()
        case .unverified(_, let error):
            AppLogger.subscription.error("Unverified transaction: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            throw error
        }
    }

    private func priority(for productID: String) -> Int {
        switch productID {
        case RoomlyProductID.weekly.rawValue:
            return 0
        case RoomlyProductID.yearly.rawValue:
            return 1
        default:
            return 2
        }
    }

    private func badge(for productID: String) -> String? {
        productID == RoomlyProductID.yearly.rawValue ? "Best value" : nil
    }
}

enum SubscriptionPurchaseError: LocalizedError {
    case cancelled
    case pending
    case unknown

    var errorDescription: String? {
        switch self {
        case .cancelled:
            "Purchase was cancelled."
        case .pending:
            "Purchase is pending approval."
        case .unknown:
            "Subscription could not complete."
        }
    }
}

private extension Product.SubscriptionPeriod {
    var localizedPeriod: String {
        switch unit {
        case .day:
            value == 1 ? "day" : "\(value) days"
        case .week:
            value == 1 ? "week" : "\(value) weeks"
        case .month:
            value == 1 ? "month" : "\(value) months"
        case .year:
            value == 1 ? "year" : "\(value) years"
        @unknown default:
            ""
        }
    }
}
