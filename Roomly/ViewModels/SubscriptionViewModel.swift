import Foundation

@MainActor
final class SubscriptionViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case processing
        case completed
        case failed(String)
    }

    @Published var selectedPlan: PremiumPlan
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var isSubscribed = false

    let plans: [PremiumPlan]
    let features: [String]

    init(
        plans: [PremiumPlan] = MockWeatherData.premiumPlans,
        features: [String] = MockWeatherData.premiumFeatures
    ) {
        self.plans = plans
        self.features = features
        self.selectedPlan = plans.last ?? PremiumPlan(id: "yearly", title: "Yearly Plan", subtitle: "$0.57 / week", price: "$29.99", period: "year", badge: "Best value")
    }

    var isProcessing: Bool {
        if case .processing = phase {
            true
        } else {
            false
        }
    }

    func select(_ plan: PremiumPlan) {
        selectedPlan = plan
        phase = .idle
    }

    func continueWithSelectedPlan() async {
        phase = .processing
        do {
            try await Task.sleep(nanoseconds: 450_000_000)
            isSubscribed = true
            phase = .completed
        } catch {
            phase = .failed("Subscription preview could not continue.")
        }
    }

    func restorePurchases() async {
        phase = .processing
        do {
            try await Task.sleep(nanoseconds: 350_000_000)
            phase = .failed("No mock purchase was found to restore.")
        } catch {
            phase = .failed("Restore is unavailable in prototype mode.")
        }
    }

    func clearError() {
        if case .failed = phase {
            phase = .idle
        }
    }
}
