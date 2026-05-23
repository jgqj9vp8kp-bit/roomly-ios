import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var locationViewModel: LocationViewModel

    let settingsRows: [SettingsRowItem]
    let onResetOnboarding: () -> Void
    let onResetRoomSettings: () -> Void
    let onShowPaywall: () -> Void
    @AppStorage("hasUserSelectedTemperatureUnit") private var hasUserSelectedTemperatureUnit = false
    @State private var showsManualLocation = false

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ScreenHeader(title: "Settings", subtitle: "Tune Roomly for your home comfort routine")
                        .padding(.top, 14)

                    premiumCard
                    preferencesCard
                    locationCard
                    appRows
                    prototypeNote
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showsManualLocation) {
            ManualLocationView(locationViewModel: locationViewModel, onSelectionComplete: {})
        }
    }

    private var premiumCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                SymbolBadge(symbol: "crown.fill", tint: RoomlyTheme.ColorToken.sun, size: 52, isFilled: true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Roomly Premium")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Unlock Monthly Outlook and richer Weather Insights.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            SecondaryPillButton(title: "View Premium", symbol: "arrow.right", action: onShowPaywall)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoomlyTheme.blueGradient, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.blue, radius: 22, x: 0, y: 14)
    }

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Preferences")

            VStack(alignment: .leading, spacing: 10) {
                Text("Temperature Units")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Picker("Temperature Units", selection: temperatureUnitBinding) {
                    ForEach(TemperatureUnit.allCases) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(14)
            .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Toggle(isOn: $viewModel.notificationsEnabled) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Notifications")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)

                    Text("Comfort shifts and pressure drops")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }
            }
            .tint(RoomlyTheme.ColorToken.primaryBlue)
            .padding(14)
            .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(18)
        .roomlyCard()
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Location")

            HStack(spacing: 12) {
                SymbolBadge(symbol: locationSymbol, tint: locationTint, size: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(locationViewModel.activeLocationDisplayName)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)

                    Text(locationSubtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }
            .padding(14)
            .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button {
                showsManualLocation = true
            } label: {
                Label("Change Location", systemImage: "mappin.and.ellipse")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(RoomlyTheme.ctaGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .roomlyCard()
    }

    private var appRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "App")

            ForEach(settingsRows) { item in
                SettingsInfoRow(symbol: item.symbol, title: item.title, subtitle: item.subtitle)
            }

            Button(role: .destructive, action: onResetOnboarding) {
                SettingsInfoRow(symbol: "arrow.counterclockwise", title: "Reset Onboarding", subtitle: "Show the intro flow again")
            }
            .buttonStyle(.plain)

            Button(role: .destructive, action: onResetRoomSettings) {
                SettingsInfoRow(symbol: "house.slash.fill", title: "Reset Room Settings", subtitle: "Use the default Indoor Estimate")
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .roomlyCard()
    }

    private var prototypeNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prototype Mode")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Text("Roomly fetches forecast data directly from Open-Meteo when a location is active, with mock fallback data for testing and outages. No backend, accounts, live sensor connections, RevenueCat, or sensor-grade indoor readings are connected.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .roomlyCard()
    }
}

private struct SettingsInfoRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            SymbolBadge(symbol: symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
        }
        .padding(.horizontal, 13)
        .frame(height: 58)
        .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private extension SettingsView {
    var locationSymbol: String {
        switch locationViewModel.locationSource {
        case .gps:
            "location.fill"
        case .manual:
            "mappin.circle.fill"
        case .none:
            "location.slash.fill"
        }
    }

    var locationTint: Color {
        switch locationViewModel.locationSource {
        case .gps:
            RoomlyTheme.ColorToken.green
        case .manual:
            RoomlyTheme.ColorToken.primaryBlue
        case .none:
            RoomlyTheme.ColorToken.orange
        }
    }

    var locationSubtitle: String {
        switch locationViewModel.locationSource {
        case .gps:
            locationViewModel.activeCoordinates?.formatted ?? "Using current device location"
        case .manual:
            locationViewModel.selectedManualCity?.subtitle ?? "Manual location saved"
        case .none:
            "No active location selected"
        }
    }

    var temperatureUnitBinding: Binding<TemperatureUnit> {
        Binding(
            get: { viewModel.temperatureUnit },
            set: { newValue in
                hasUserSelectedTemperatureUnit = true
                viewModel.temperatureUnit = newValue
            }
        )
    }
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(),
        locationViewModel: LocationViewModel(),
        settingsRows: MockWeatherData.settings,
        onResetOnboarding: {},
        onResetRoomSettings: {},
        onShowPaywall: {}
    )
}
