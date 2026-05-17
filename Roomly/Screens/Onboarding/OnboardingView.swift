import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var selectedPage = 0
    @State private var selectedUnit = "Celsius"

    private let pages = MockOnboardingData.pages
    private let unitOptions = MockOnboardingData.unitOptions

    var body: some View {
        ZStack {
            RoomlyBackground()

            VStack(spacing: 20) {
                skipButton
                pager
                unitCard
                actionButton
            }
            .padding(.horizontal, RoomlyTheme.Spacing.page)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .preferredColorScheme(.dark)
    }

    private var skipButton: some View {
        HStack {
            Spacer()

            Button("Skip") {
                onComplete()
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white.opacity(0.70))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.white.opacity(0.08), in: Capsule())
            .buttonStyle(.plain)
            .accessibilityLabel("Skip onboarding")
        }
    }

    private var pager: some View {
        TabView(selection: $selectedPage) {
            ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                OnboardingPageView(page: page)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            pageDots
                .padding(.bottom, 10)
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == selectedPage ? Color.cyan : Color.white.opacity(0.22))
                    .frame(width: index == selectedPage ? 22 : 7, height: 7)
                    .animation(.spring(response: 0.28, dampingFraction: 0.8), value: selectedPage)
            }
        }
        .accessibilityHidden(true)
    }

    private var unitCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Preferred Units", symbol: "slider.horizontal.3")

            HStack(spacing: 10) {
                ForEach(unitOptions, id: \.self) { unit in
                    Button {
                        selectedUnit = unit
                    } label: {
                        Text(unit)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selectedUnit == unit ? .black.opacity(0.82) : .white.opacity(0.72))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(
                                selectedUnit == unit ? AnyShapeStyle(RoomlyTheme.premium) : AnyShapeStyle(Color.white.opacity(0.08)),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 24, glow: selectedPage == pages.count - 1)
        .cardEntrance(delay: 0.18)
    }

    private var actionButton: some View {
        PremiumButton(title: selectedPage == pages.count - 1 ? "Enter Roomly" : "Continue", symbol: "arrow.right") {
            if selectedPage == pages.count - 1 {
                onComplete()
            } else {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                    selectedPage += 1
                }
            }
        }
        .cardEntrance(delay: 0.26)
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 8)

            ZStack {
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .fill(RoomlyTheme.aurora)
                    .frame(width: 224, height: 224)
                    .opacity(0.46)
                    .shadow(color: page.accent.opacity(0.22), radius: 30, x: 0, y: 18)

                Image(systemName: page.symbol)
                    .font(.system(size: 82, weight: .thin))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(page.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .cardEntrance(delay: 0.05)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.82)

                Text(page.subtitle)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.66))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
            .glassCard(cornerRadius: 30, glow: true)
            .cardEntrance(delay: 0.12)

            Spacer(minLength: 42)
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .preferredColorScheme(.dark)
}
