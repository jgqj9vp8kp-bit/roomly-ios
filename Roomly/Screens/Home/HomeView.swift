import SwiftUI

struct HomeView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var locationViewModel: LocationViewModel
    let onShowPaywall: () -> Void
    @State private var showsManualLocation = false

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    content
                }
                .padding(.horizontal, RoomlyTheme.Spacing.screenHorizontal)
                .padding(.bottom, 28)
            }
            .refreshable {
                await weatherViewModel.reload()
            }
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await weatherViewModel.loadIfNeeded()
        }
        .fullScreenCover(isPresented: $showsManualLocation) {
            ManualLocationView(locationViewModel: locationViewModel, onSelectionComplete: {})
        }
    }

    @ViewBuilder
    private var content: some View {
        switch weatherViewModel.phase {
        case .idle, .loading:
            loadingContent
        case .loaded:
            if let dashboard = weatherViewModel.dashboard {
                loadedContent(dashboard)
            } else {
                emptyContent("No Weather Insights are available yet.")
            }
        case .empty(let message):
            emptyContent(message)
        case .failed(let message):
            errorContent(message)
        }
    }

    private var loadingContent: some View {
        VStack(spacing: 16) {
            SkeletonCard(height: 58, cornerRadius: 18)
                .padding(.top, RoomlyTheme.Spacing.screenTop)
            SkeletonCard(height: 212, cornerRadius: 24)
            SkeletonCard(height: 212, cornerRadius: 24)
            SkeletonCard(height: 212, cornerRadius: 24)
            LoadingStateView(title: "Loading Weather Insights", subtitle: "Preparing your Indoor Comfort overview.")
        }
    }

    private func loadedContent(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 16) {
            ScreenHeader(
                title: "Roomly",
                subtitle: dashboardSubtitle(for: dashboard),
                trailingSymbol: "crown.fill",
                trailingAction: onShowPaywall
            )
            .padding(.top, RoomlyTheme.Spacing.screenTop)
            .cardEntrance(delay: 0.03)

            LocationStateCard(viewModel: locationViewModel) {
                showsManualLocation = true
            }
                .cardEntrance(delay: 0.05)

            if let fallbackNotice = weatherViewModel.fallbackNotice {
                WeatherFallbackNotice(message: fallbackNotice)
                    .cardEntrance(delay: 0.06)
            }

            NavigationLink(value: RoomlyRoute.roomSetup) {
                ComfortGaugeDashboardCard(dashboard: dashboard, unit: weatherViewModel.temperatureUnit)
                    .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(PressableButtonStyle(scale: 0.985))
            .simultaneousGesture(TapGesture().onEnded { HapticFeedback.light() })
            .cardEntrance(delay: 0.08)

            NavigationLink(value: RoomlyRoute.weatherInfo) {
                DashboardWeatherCard(
                    title: "Location Forecast",
                    subtitle: dashboard.snapshot.condition,
                    value: dashboard.snapshot.outdoorTemperature,
                    footnote: dashboard.comfort.outdoorInsight,
                    symbol: "cloud.sun.fill",
                    gradient: RoomlyTheme.orangeGradient
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { HapticFeedback.light() })
            .cardEntrance(delay: 0.13)

            NavigationLink(value: RoomlyRoute.monthlyOutlook) {
                DashboardWeatherCard(
                    title: "Weather Insights",
                    subtitle: "Monthly Outlook",
                    value: "7d",
                    footnote: dashboard.comfort.weeklyTrendInsight,
                    symbol: "calendar",
                    gradient: RoomlyTheme.purpleGradient
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { HapticFeedback.light() })
            .cardEntrance(delay: 0.18)

            metricGrid(dashboard.dashboardMetrics)
                .cardEntrance(delay: 0.23)

            NavigationLink(value: RoomlyRoute.roomSetup) {
                roomSetupRow
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { HapticFeedback.light() })
            .cardEntrance(delay: 0.28)

            dailyInsights(dashboard)
                .cardEntrance(delay: 0.33)
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.86), value: dashboard.comfort.index)
    }

    private var roomSetupRow: some View {
        HStack(spacing: 12) {
            SymbolBadge(symbol: "slider.horizontal.3", tint: RoomlyTheme.ColorToken.primaryBlue, size: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text("Set Room Info")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text("Update room conditions for Indoor Comfort insights.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
        }
        .padding(14)
        .roomlyCard()
    }

    private func dashboardSubtitle(for dashboard: WeatherDashboard) -> String {
        "\(locationViewModel.activeLocationDisplayName) · \(dashboard.snapshot.updatedAt)"
    }

    private func metricGrid(_ metrics: [WeatherMetric]) -> some View {
        VStack(spacing: 10) {
            ForEach(metrics.chunked(into: 2), id: \.first?.id) { row in
                HStack(spacing: 10) {
                    ForEach(row) { metric in
                        GlassMetricCard(metric: metric)
                    }
                }
            }
        }
    }

    private func dailyInsights(_ dashboard: WeatherDashboard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "Daily Insights", trailing: dashboard.comfort.level.rawValue)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    DailyInsightCard(
                        symbol: "figure.walk",
                        title: "Best Outside",
                        message: "Best comfort in forecast: \(dashboard.comfort.bestComfortDay).",
                        tint: RoomlyTheme.ColorToken.green
                    )

                    DailyInsightCard(
                        symbol: "moon.fill",
                        title: "Sleep Tonight",
                        message: dashboard.comfort.sleepComfort.message,
                        tint: RoomlyTheme.ColorToken.purple
                    )

                    DailyInsightCard(
                        symbol: "cloud.rain.fill",
                        title: "Rain Risk",
                        message: dashboard.comfort.rainRisk.message,
                        tint: RoomlyTheme.ColorToken.primaryBlue
                    )

                    DailyInsightCard(
                        symbol: "humidity.fill",
                        title: "Humidity",
                        message: dashboard.comfort.humidityComfort.message,
                        tint: RoomlyTheme.ColorToken.sky
                    )
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func emptyContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            ScreenHeader(title: "Roomly", subtitle: "Weather Insights")
                .padding(.top, RoomlyTheme.Spacing.screenTop)
            DataStateView(symbol: "cloud.slash.fill", title: "Weather is waiting", message: "Choose a location or refresh when you are back online. Roomly will keep the experience graceful.", actionTitle: "Reload") {
                Task {
                    await weatherViewModel.reload()
                }
            }
        }
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            ScreenHeader(title: "Roomly", subtitle: "Weather Insights")
                .padding(.top, RoomlyTheme.Spacing.screenTop)
            DataStateView(symbol: "exclamationmark.triangle.fill", title: "Weather needs a moment", message: "Live conditions did not arrive cleanly. Try again and Roomly will fall back softly if needed.", actionTitle: "Try Again") {
                Task {
                    await weatherViewModel.reload()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(
            weatherViewModel: WeatherViewModel(),
            locationViewModel: LocationViewModel(),
            onShowPaywall: {}
        )
    }
}

private struct LocationStateCard: View {
    @ObservedObject var viewModel: LocationViewModel
    let onManualLocation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                SymbolBadge(symbol: symbol, tint: tint, size: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)

                    Text(message)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(RoomlyTheme.ColorToken.primaryBlue)
                }
            }

            if shouldShowActions {
                HStack(spacing: 10) {
                    Button {
                        Task {
                            _ = await viewModel.requestPermissionAndFetchLocation()
                        }
                    } label: {
                        Label("Allow Location", systemImage: "location.fill")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(RoomlyTheme.ctaGradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onManualLocation()
                    } label: {
                        Label("Enter Location Manually", systemImage: "keyboard")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(RoomlyTheme.ColorToken.surfaceBlue, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .roomlyCard(cornerRadius: 20)
    }

    private var shouldShowActions: Bool {
        viewModel.locationSource == .none
    }

    private var symbol: String {
        if viewModel.locationSource == .manual {
            return "mappin.circle.fill"
        }

        if viewModel.locationSource == .gps {
            return "location.fill"
        }
        return "location.slash.fill"
    }

    private var tint: Color {
        if viewModel.locationSource == .manual {
            return RoomlyTheme.ColorToken.primaryBlue
        }

        if viewModel.locationSource == .gps {
            return RoomlyTheme.ColorToken.green
        }
        return RoomlyTheme.ColorToken.orange
    }

    private var title: String {
        if viewModel.locationSource != .none {
            return viewModel.activeLocationDisplayName
        }

        return "Location not enabled"
    }

    private var message: String {
        if viewModel.locationSource == .manual {
            return "Manual city selected · mock Weather Insights remain active."
        }

        if viewModel.locationSource == .gps {
            return viewModel.activeCoordinates?.formatted ?? "Location permission is enabled."
        }

        if let errorMessage = viewModel.errorMessage {
            return errorMessage
        }

        return "Enable location for local context, or continue with mock data."
    }
}
