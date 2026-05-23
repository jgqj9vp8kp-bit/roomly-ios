import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SubscriptionViewModel

    var showsCloseButton = true
    var onContinue: (() -> Void)?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                hero
                    .frame(height: 310)
                    .ignoresSafeArea(edges: .top)

                bodyContent
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(Color.white)
            }

            if viewModel.isProcessing {
                Color.white.opacity(0.62)
                    .ignoresSafeArea()

                LoadingStateView(title: "Preparing Premium", subtitle: "Mock subscription flow is running.")
                    .padding(32)
            }
        }
        .preferredColorScheme(.light)
    }

    private var hero: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .topTrailing) {
                Image("PaywallWeatherPhoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()

                LinearGradient(
                    colors: [
                        Color(red: 0.098, green: 0.459, blue: 0.957).opacity(0.85),
                        Color(red: 0.039, green: 0.341, blue: 0.847).opacity(0.70),
                        .white.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 1.0, green: 0.898, blue: 0.561).opacity(0.80), RoomlyTheme.ColorToken.sun.opacity(0.40), .clear],
                            center: .center,
                            startRadius: 8,
                            endRadius: 52
                        )
                    )
                    .frame(width: 102, height: 102)
                    .blur(radius: 8)
                    .position(x: width * 0.45, y: 117)

                if showsCloseButton {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.18), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 56)
                    .padding(.trailing, 32)
                }

                PremiumThermometerCard()
                    .frame(width: 92, height: 156)
                    .position(x: width * 0.19, y: 150)

                PaywallHeroMetric(symbol: "thermometer.medium", title: "Feel", value: "Hot", tint: RoomlyTheme.ColorToken.orange)
                    .position(x: width * 0.55, y: 197)

                PaywallHeroMetric(symbol: "wind", title: "Wind", value: "10 km/h", tint: Color(red: 0.655, green: 0.953, blue: 1.0))
                    .position(x: width * 0.80, y: 197)

                PaywallHeroMetric(symbol: "house.fill", title: "Inside", value: "22 °C", tint: .white)
                    .position(x: width * 0.45, y: 249)

                PaywallHeroMetric(symbol: "sun.max.fill", title: "Outside", value: "26.2 °C", tint: RoomlyTheme.ColorToken.sun)
                    .position(x: width * 0.70, y: 249)
            }
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 34, bottomLeadingRadius: 30, bottomTrailingRadius: 30, topTrailingRadius: 34, style: .continuous))
        }
    }

    private var bodyContent: some View {
        VStack(spacing: 12) {
            VStack(spacing: 5) {
                Text("Indoor Comfort")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text("Weather Intelligence")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .italic()
                    .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)

                Text("Smart Indoor Estimate insights and Weather Insights.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)

            VStack(spacing: 8) {
                ForEach(Array(viewModel.features.enumerated()), id: \.offset) { _, feature in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(RoomlyTheme.ColorToken.primaryBlue)
                            .frame(width: 10, height: 10)

                        Text(feature)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(RoomlyTheme.ColorToken.ink)

                        Spacer()
                    }
                    .frame(height: 24)
                }
            }
            .padding(.top, 4)

            VStack(spacing: 10) {
                ForEach(viewModel.plans) { plan in
                    PricingCard(plan: plan, isSelected: viewModel.selectedPlan == plan) {
                        viewModel.select(plan)
                    }
                }
            }
            .padding(.top, 2)
            .animation(.spring(response: 0.34, dampingFraction: 0.82), value: viewModel.selectedPlan)

            if case .failed(let message) = viewModel.phase {
                Text(message)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.red)
                    .multilineTextAlignment(.center)
            }

            PremiumButton(title: "Continue") {
                Task {
                    await viewModel.continueWithSelectedPlan()
                    if case .completed = viewModel.phase {
                        HapticFeedback.success()
                        if let onContinue {
                            onContinue()
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .padding(.top, 2)

            Text("Cancel anytime. Secure subscription. Your plan renews automatically and can be managed in App Store settings.")
                .font(.system(size: 10, weight: .semibold))
                .lineSpacing(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)

            HStack {
                Text("Terms of Use")
                Spacer()
                Text("Privacy Policy")
                Spacer()
                Button("Restore Purchases") {
                    Task {
                        await viewModel.restorePurchases()
                    }
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(RoomlyTheme.ColorToken.ink)
            .frame(height: 22)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }

}

private struct PremiumThermometerCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white, lineWidth: 1))
                .shadow(color: Color(red: 0.039, green: 0.239, blue: 0.541).opacity(0.25), radius: 16, x: 0, y: 8)

            VStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(red: 0.867, green: 0.945, blue: 1.0), Color(red: 0.482, green: 0.780, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)

                    Image(systemName: "thermometer.sun.fill")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                }

                Text("ROOM")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)

                Text("22°")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text("Comfort")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                    .padding(.horizontal, 9)
                    .frame(height: 18)
                    .background(RoomlyTheme.ColorToken.surfaceBlue, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(RoomlyTheme.ColorToken.border, lineWidth: 1))
            }
            .padding(.vertical, 16)
        }
    }
}

private struct PaywallHeroMetric: View {
    let symbol: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.white)
                Text(value)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(Color(red: 0.918, green: 0.957, blue: 1.0))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 9)
        .frame(width: 94, height: 42)
        .background(Color.white.opacity(0.20), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.25), lineWidth: 1))
    }
}

#Preview {
    PaywallView(viewModel: SubscriptionViewModel())
}
