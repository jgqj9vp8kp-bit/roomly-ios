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
                    .frame(height: 252)

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
        ZStack(alignment: .topTrailing) {
            RoomlyTheme.blueGradient

            Circle()
                .fill(Color.white.opacity(0.20))
                .frame(width: 154, height: 154)
                .offset(x: 44, y: -54)

            Circle()
                .fill(RoomlyTheme.ColorToken.sun)
                .frame(width: 94, height: 94)
                .shadow(color: RoomlyTheme.ColorToken.sun.opacity(0.45), radius: 18, x: 0, y: 8)
                .position(x: 146, y: 56)

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
                .padding(.top, 28)
                .padding(.trailing, 22)
            }

            PremiumThermometerCard()
                .frame(width: 86, height: 166)
                .position(x: 67, y: 111)

            RoomlyWeatherCloud()
                .frame(width: 142, height: 78)
                .position(x: 193, y: 82)

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    PaywallHeroMetric(symbol: "thermometer.medium", title: "Indoor", value: "15°", tint: RoomlyTheme.ColorToken.orange)
                    PaywallHeroMetric(symbol: "wind", title: "Wind", value: "11", tint: Color(red: 0.655, green: 0.953, blue: 1.0))
                }

                HStack(spacing: 6) {
                    PaywallHeroMetric(symbol: "house.fill", title: "Comfort", value: "82", tint: .white)
                    PaywallHeroMetric(symbol: "sun.max.fill", title: "Outlook", value: "7d", tint: RoomlyTheme.ColorToken.sun)
                }
            }
            .frame(width: 230)
            .position(x: 260, y: 166)
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 30, bottomTrailingRadius: 30, topTrailingRadius: 0, style: .continuous))
    }

    private var bodyContent: some View {
        VStack(spacing: 12) {
            VStack(spacing: 5) {
                Text("Estimated Room Comfort")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text("Thermometer")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .italic()
                    .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)

                Text("Smart indoor comfort insights and weather forecasts.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)

            VStack(spacing: 8) {
                ForEach(Array(viewModel.features.enumerated()), id: \.offset) { _, feature in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(RoomlyTheme.ColorToken.green)

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

            trustRow

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

    private var trustRow: some View {
        HStack(spacing: 8) {
            Label("App Store billing", systemImage: "lock.shield.fill")
            Circle().fill(RoomlyTheme.ColorToken.tertiaryInk.opacity(0.35)).frame(width: 4, height: 4)
            Label("Mock preview", systemImage: "sparkles")
        }
        .font(.system(size: 11, weight: .heavy))
        .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(RoomlyTheme.ColorToken.surfaceBlue, in: Capsule())
        .overlay(Capsule().stroke(RoomlyTheme.ColorToken.border, lineWidth: 1))
    }
}

private struct PremiumThermometerCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white, lineWidth: 1))
                .shadow(color: Color(red: 0.039, green: 0.239, blue: 0.541).opacity(0.25), radius: 16, x: 0, y: 8)

            VStack(spacing: 8) {
                Text("20")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 14)

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.953, green: 0.969, blue: 0.988))
                        .frame(width: 16, height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(RoomlyTheme.ColorToken.border, lineWidth: 1))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(RoomlyTheme.ColorToken.red)
                        .frame(width: 6, height: 66)
                        .padding(.bottom, 2)

                    Circle()
                        .fill(RoomlyTheme.ColorToken.red)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(.white, lineWidth: 5))
                        .offset(y: 15)
                }
            }
            .padding(.vertical, 22)
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
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white.opacity(0.76))
                Text(value)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
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
