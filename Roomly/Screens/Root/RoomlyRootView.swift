import SwiftUI

enum RoomlyTab: Hashable {
    case home
    case forecast
    case settings

    var title: String {
        switch self {
        case .home:
            "Home"
        case .forecast:
            "Forecast"
        case .settings:
            "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home:
            "house.fill"
        case .forecast:
            "calendar"
        case .settings:
            "gearshape.fill"
        }
    }
}

struct RoomlyRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("temperatureUnit") private var temperatureUnitRawValue = TemperatureUnit.celsius.rawValue
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    @State private var selectedTab: RoomlyTab = .home
    @State private var showsPaywall = false

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                appTabs
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.32)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showsPaywall) {
            PaywallView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var appTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(temperatureUnit: temperatureUnit.wrappedValue, onShowPaywall: showPaywall)
            }
            .tabItem {
                Label(RoomlyTab.home.title, systemImage: RoomlyTab.home.symbol)
            }
            .tag(RoomlyTab.home)

            NavigationStack {
                ForecastView()
            }
            .tabItem {
                Label(RoomlyTab.forecast.title, systemImage: RoomlyTab.forecast.symbol)
            }
            .tag(RoomlyTab.forecast)

            NavigationStack {
                SettingsView(
                    temperatureUnit: temperatureUnit,
                    notificationsEnabled: $notificationsEnabled,
                    onResetOnboarding: resetOnboarding,
                    onShowPaywall: showPaywall
                )
            }
            .tabItem {
                Label(RoomlyTab.settings.title, systemImage: RoomlyTab.settings.symbol)
            }
            .tag(RoomlyTab.settings)
        }
        .tint(.cyan)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .animation(.easeInOut(duration: 0.22), value: selectedTab)
    }

    private var temperatureUnit: Binding<TemperatureUnit> {
        Binding {
            TemperatureUnit(rawValue: temperatureUnitRawValue) ?? .celsius
        } set: { newValue in
            temperatureUnitRawValue = newValue.rawValue
        }
    }

    private func showPaywall() {
        showsPaywall = true
    }

    private func resetOnboarding() {
        selectedTab = .home
        withAnimation(.easeInOut(duration: 0.28)) {
            hasCompletedOnboarding = false
        }
    }
}

#Preview {
    RoomlyRootView()
}
