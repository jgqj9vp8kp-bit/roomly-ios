import SwiftUI

struct SettingsView: View {
    @Binding var temperatureUnit: TemperatureUnit
    @Binding var notificationsEnabled: Bool

    let onResetOnboarding: () -> Void
    let onShowPaywall: () -> Void

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: RoomlyTheme.Spacing.section) {
                    ScreenHeader(title: "Settings", subtitle: "Tune Roomly for the way your home feels")
                        .cardEntrance(delay: 0.04)
                    premiumCard
                        .cardEntrance(delay: 0.10)
                    preferencesCard
                        .cardEntrance(delay: 0.16)
                    appControlsCard
                        .cardEntrance(delay: 0.22)
                    footerCard
                        .cardEntrance(delay: 0.28)
                }
                .padding(.horizontal, RoomlyTheme.Spacing.page)
                .padding(.top, 18)
                .padding(.bottom, 38)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var premiumCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black.opacity(0.82))
                    .frame(width: 50, height: 50)
                    .background(RoomlyTheme.premium, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Roomly Premium")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Status: Preview placeholder")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.62))
                }
            }

            PremiumButton(title: "View Premium", action: onShowPaywall)
        }
        .padding(20)
        .glassCard(cornerRadius: 28, glow: true)
    }

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionTitle(title: "Preferences", symbol: "slider.horizontal.3")

            VStack(alignment: .leading, spacing: 10) {
                Text("Temperature Units")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Picker("Temperature Units", selection: $temperatureUnit) {
                    ForEach(TemperatureUnit.allCases) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(14)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: RoomlyTheme.Radius.control, style: .continuous))

            Toggle(isOn: $notificationsEnabled) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Notifications")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Comfort shifts and pressure drops")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.52))
                }
            }
            .tint(.cyan)
            .padding(14)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: RoomlyTheme.Radius.control, style: .continuous))
        }
        .padding(18)
        .glassCard(cornerRadius: 28)
    }

    private var appControlsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "App", symbol: "gearshape.fill")

            SettingsInfoRow(symbol: "checkmark.seal.fill", title: "Premium Status", subtitle: "Preview mode, no purchase system connected")

            Button(role: .destructive, action: onResetOnboarding) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 17, weight: .semibold))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Reset Onboarding")
                            .font(.subheadline.weight(.semibold))

                        Text("Show the intro flow on next screen")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.52))
                    }

                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(14)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: RoomlyTheme.Radius.control, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .glassCard(cornerRadius: 28)
    }

    private var footerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prototype Mode")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Text("Roomly is currently using mock weather data only. No backend, accounts, or live sensor connections are included yet.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .glassCard(cornerRadius: 24)
    }
}

private struct SettingsInfoRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.cyan)
                .frame(width: 38, height: 38)
                .background(Color.white.opacity(0.08), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.52))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    SettingsView(
        temperatureUnit: .constant(.celsius),
        notificationsEnabled: .constant(true),
        onResetOnboarding: {},
        onShowPaywall: {}
    )
        .preferredColorScheme(.dark)
}
