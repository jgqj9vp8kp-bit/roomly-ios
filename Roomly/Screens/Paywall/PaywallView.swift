import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    private let features = MockWeatherData.premiumFeatures

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    closeButton
                    crownHero
                        .cardEntrance(delay: 0.05)
                    trustStrip
                        .cardEntrance(delay: 0.11)
                    featureList
                        .cardEntrance(delay: 0.17)
                    pricingCard
                        .cardEntrance(delay: 0.24)
                }
                .padding(.horizontal, RoomlyTheme.Spacing.page)
                .padding(.top, 18)
                .padding(.bottom, 34)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var closeButton: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.10), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close paywall")
        }
    }

    private var crownHero: some View {
        VStack(spacing: 18) {
            Image(systemName: "crown.fill")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(.black.opacity(0.82))
                .frame(width: 96, height: 96)
                .background(RoomlyTheme.premium, in: Circle())
                .shadow(color: .cyan.opacity(0.26), radius: 28, x: 0, y: 18)

            VStack(spacing: 8) {
                Text("Roomly Premium")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("A calmer, richer read on comfort trends and Local Weather context.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.64))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 10)
    }

    private var trustStrip: some View {
        HStack(spacing: 12) {
            TrustItem(symbol: "sparkles", title: "Mock Preview")
            TrustItem(symbol: "lock.shield.fill", title: "No Account")
            TrustItem(symbol: "cloud.sun.fill", title: "No API Yet")
        }
        .padding(14)
        .glassCard(cornerRadius: 24)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Included", symbol: "checkmark.seal.fill")

            ForEach(features, id: \.self) { feature in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.mint)

                    Text(feature)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.86))

                    Spacer()
                }
                .padding(14)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 28)
    }

    private var pricingCard: some View {
        VStack(spacing: 18) {
            VStack(spacing: 4) {
                Text("Premium Preview")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.gold)

                Text("$4.99")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("per month • mock paywall")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.56))
            }

            PremiumButton(title: "Start Premium") {
                dismiss()
            }

            Button("Restore Purchases") {}
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))
                .padding(.top, 2)
                .buttonStyle(.plain)
        }
        .padding(20)
        .glassCard(cornerRadius: 28, glow: true)
    }
}

private struct TrustItem: View {
    let symbol: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.cyan)

            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    PaywallView()
        .preferredColorScheme(.dark)
}
