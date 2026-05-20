import SwiftUI

enum RoomlyRoute: Hashable {
    case roomSetup
    case roomDetail
    case weatherInfo
    case monthlyOutlook
}

enum RoomlyTab: Hashable {
    case home
    case weather
    case settings

    var title: String {
        switch self {
        case .home:
            "Home"
        case .weather:
            "Weather"
        case .settings:
            "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home:
            "house.fill"
        case .weather:
            "cloud.sun.fill"
        case .settings:
            "gearshape.fill"
        }
    }
}

struct RoomlyRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("temperatureUnit") private var temperatureUnitRawValue = TemperatureUnit.celsius.rawValue
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()
    @StateObject private var locationViewModel = LocationViewModel()

    @State private var selectedTab: RoomlyTab = .home
    @State private var showsPaywall = false
    @State private var isEnteringFromOnboarding = false

    var body: some View {
        ZStack {
            if settingsViewModel.hasCompletedOnboarding {
                appTabs
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView(locationViewModel: locationViewModel) {
                    isEnteringFromOnboarding = true
                    showsPaywall = true
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.light)
        .task {
            syncSettingsFromStorage()
            await locationViewModel.fetchLocationIfAuthorized()
            await weatherViewModel.loadIfNeeded()
        }
        .onChange(of: settingsViewModel.hasCompletedOnboarding) { _, newValue in
            hasCompletedOnboarding = newValue
        }
        .onChange(of: settingsViewModel.temperatureUnit) { _, newValue in
            temperatureUnitRawValue = newValue.rawValue
            Task {
                await weatherViewModel.reload(unit: newValue)
            }
        }
        .onChange(of: settingsViewModel.notificationsEnabled) { _, newValue in
            notificationsEnabled = newValue
        }
        .fullScreenCover(isPresented: $showsPaywall) {
            PaywallView(
                viewModel: subscriptionViewModel,
                showsCloseButton: !isEnteringFromOnboarding
            ) {
                completePaywall()
            }
        }
    }

    private var appTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    weatherViewModel: weatherViewModel,
                    locationViewModel: locationViewModel,
                    onShowPaywall: showPaywall
                )
                    .navigationDestination(for: RoomlyRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label(RoomlyTab.home.title, systemImage: RoomlyTab.home.symbol)
            }
            .tag(RoomlyTab.home)

            NavigationStack {
                ForecastView(weatherViewModel: weatherViewModel)
                    .navigationDestination(for: RoomlyRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label(RoomlyTab.weather.title, systemImage: RoomlyTab.weather.symbol)
            }
            .tag(RoomlyTab.weather)

            NavigationStack {
                SettingsView(
                    viewModel: settingsViewModel,
                    locationViewModel: locationViewModel,
                    settingsRows: weatherViewModel.dashboard?.settingsRows ?? MockWeatherData.settings,
                    onResetOnboarding: resetOnboarding,
                    onShowPaywall: showPaywall
                )
                .navigationDestination(for: RoomlyRoute.self) { route in
                    destination(for: route)
                }
            }
            .tabItem {
                Label(RoomlyTab.settings.title, systemImage: RoomlyTab.settings.symbol)
            }
            .tag(RoomlyTab.settings)
        }
        .tint(RoomlyTheme.ColorToken.primaryBlue)
        .toolbarBackground(.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.light, for: .tabBar)
    }

    @ViewBuilder
    private func destination(for route: RoomlyRoute) -> some View {
        switch route {
        case .roomSetup:
            RoomSetupView(weatherViewModel: weatherViewModel)
        case .roomDetail:
            RoomDetailView(weatherViewModel: weatherViewModel)
        case .weatherInfo:
            WeatherInfoView(weatherViewModel: weatherViewModel)
        case .monthlyOutlook:
            MonthlyOutlookView(weatherViewModel: weatherViewModel)
        }
    }

    private func syncSettingsFromStorage() {
        settingsViewModel.hasCompletedOnboarding = hasCompletedOnboarding
        settingsViewModel.temperatureUnit = TemperatureUnit(rawValue: temperatureUnitRawValue) ?? .celsius
        settingsViewModel.notificationsEnabled = notificationsEnabled
    }

    private func showPaywall() {
        isEnteringFromOnboarding = false
        showsPaywall = true
    }

    private func completePaywall() {
        showsPaywall = false

        if isEnteringFromOnboarding {
            isEnteringFromOnboarding = false
            withAnimation(.easeInOut(duration: 0.28)) {
                settingsViewModel.completeOnboarding()
            }
        }
    }

    private func resetOnboarding() {
        selectedTab = .home
        subscriptionViewModel.clearError()
        withAnimation(.easeInOut(duration: 0.28)) {
            settingsViewModel.resetOnboarding()
        }
    }
}

#Preview {
    RoomlyRootView()
}
