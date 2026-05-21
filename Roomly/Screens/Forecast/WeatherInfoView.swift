import SwiftUI

struct WeatherInfoView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    DetailNavigationBar(title: "Weather Info", trailingSymbol: "location.fill") {}
                        .padding(.top, 14)

                    content
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
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
                DataStateView(symbol: "cloud.slash.fill", title: "No forecast yet", message: "No Weather Insights are available yet.", actionTitle: "Reload") {
                    Task { await weatherViewModel.reload() }
                }
            }
        case .empty(let message):
            DataStateView(symbol: "cloud.slash.fill", title: "No forecast yet", message: message, actionTitle: "Reload") {
                Task { await weatherViewModel.reload() }
            }
        case .failed(let message):
            DataStateView(symbol: "exclamationmark.triangle.fill", title: "Weather Info unavailable", message: message, actionTitle: "Try Again") {
                Task { await weatherViewModel.reload() }
            }
        }
    }

    private var loadingContent: some View {
        VStack(spacing: 14) {
            SkeletonCard(height: 52, cornerRadius: 18)
            SkeletonCard(height: 208, cornerRadius: 28)
            SkeletonCard(height: 78, cornerRadius: 18)
            SkeletonCard(height: 156, cornerRadius: 24)
            LoadingStateView(title: "Loading Weather Info", subtitle: "Fetching local hourly, weekly, and metric data.")
        }
    }

    private func loadedContent(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(dashboard.snapshot.location)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Label(dashboard.snapshot.updatedAt, systemImage: "location.north.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let fallbackNotice = weatherViewModel.fallbackNotice {
                WeatherFallbackNotice(message: fallbackNotice)
            }

            mainWeatherCard(dashboard)
            maxMinRow(dashboard)
            hourlyForecast(dashboard.hourly)

            SectionTitle(title: "Weekly Forecast")
            weeklyForecast(dashboard.daily)

            comfortInsightRow(dashboard)

            SectionTitle(title: "Weather Metrics")
            metricsGrid(dashboard.weatherMetrics)

            weatherAlerts(dashboard)
            bestTimeCard(dashboard)
        }
    }

    private func mainWeatherCard(_ dashboard: WeatherDashboard) -> some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [RoomlyTheme.ColorToken.sky, Color(red: 0.184, green: 0.502, blue: 0.929), RoomlyTheme.ColorToken.deepBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle().fill(.white.opacity(0.18)).frame(width: 142, height: 142).offset(x: 38, y: -42)
            Circle().fill(Color(red: 0.741, green: 0.91, blue: 1).opacity(0.20)).frame(width: 88, height: 88).offset(x: -264, y: 112)

            VStack(alignment: .leading, spacing: 12) {
                Text(dashboard.snapshot.condition)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)

                Text("Feels like \(dashboard.snapshot.feelsLike)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 0.863, green: 0.922, blue: 1.0))

                Text(dashboard.snapshot.outdoorTemperature)
                    .font(.system(size: 78, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text("\(dashboard.snapshot.wind) wind · \(dashboard.snapshot.humidity) humidity")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 0.918, green: 0.957, blue: 1.0))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)

            RoomlyWeatherCloud()
                .frame(width: 104, height: 82)
                .padding(.top, 34)
                .padding(.trailing, 30)
        }
        .frame(height: 208)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.blue, radius: 24, x: 0, y: 14)
        .animation(.spring(response: 0.55, dampingFraction: 0.84), value: dashboard.snapshot.outdoorTemperature)
    }

    private func maxMinRow(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 12) {
            WeatherStatCard(title: "Max Temperature", value: "\(dashboard.daily.first?.high ?? 20)°", symbol: "thermometer.sun.fill")
            WeatherStatCard(title: "Min Temperature", value: "\(dashboard.daily.first?.low ?? 13)°", symbol: "thermometer.low")
        }
        .frame(height: 78)
    }

    private func hourlyForecast(_ hourly: [HourlyForecast]) -> some View {
        VStack(spacing: 10) {
            SectionTitle(title: "Hourly Forecast", trailing: "Today")

            if hourly.isEmpty {
                Text("No hourly forecast is available.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .frame(maxWidth: .infinity, minHeight: 104)
            } else {
                HStack(spacing: 10) {
                    ForEach(hourly) { item in
                        VStack(spacing: 8) {
                            Text(item.time)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Image(systemName: item.symbol)
                                .font(.system(size: 22, weight: .bold))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue, RoomlyTheme.ColorToken.sun)

                            Text(item.temperature)
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                                .foregroundStyle(RoomlyTheme.ColorToken.ink)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 104)
                        .background(item.time == "Now" ? RoomlyTheme.ColorToken.tileSelected : .white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: RoomlyTheme.Shadow.soft.opacity(0.55), radius: 12, x: 0, y: 5)
                    }
                }
            }
        }
        .padding(14)
        .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.soft, radius: 18, x: 0, y: 8)
    }

    private func weeklyForecast(_ daily: [DailyForecast]) -> some View {
        VStack(spacing: 9) {
            if daily.isEmpty {
                Text("No weekly forecast is available.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                ForEach(daily) { item in
                    ForecastListRow(item: item)
                }
            }
        }
        .padding(14)
        .roomlyCard(cornerRadius: 22)
    }

    private func comfortInsightRow(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 12) {
            SmallInfoCard(title: "Outdoor Comfort", value: dashboard.comfort.outdoorComfort.message, symbol: "figure.walk", tint: RoomlyTheme.ColorToken.green)
            SmallInfoCard(title: "Comfort Insight", value: dashboard.comfort.outdoorInsight, symbol: "sparkles", tint: RoomlyTheme.ColorToken.primaryBlue)
        }
        .frame(height: 96)
    }

    private func metricsGrid(_ metrics: [WeatherMetric]) -> some View {
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

    private func weatherAlerts(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 10) {
            Image(systemName: dashboard.comfort.rainRisk.level == .poor ? "cloud.rain.fill" : "checkmark.shield.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(dashboard.comfort.rainRisk.level == .poor ? RoomlyTheme.ColorToken.primaryBlue : RoomlyTheme.ColorToken.green)
            Text(dashboard.comfort.rainRisk.message)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .roomlyCard(cornerRadius: 18)
    }

    private func bestTimeCard(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            Text("Best comfort in forecast:\n\(dashboard.comfort.bestComfortDay)")
                .font(.system(size: 14, weight: .heavy))
                .lineSpacing(2)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 62)
        .background(RoomlyTheme.ctaGradient, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.blue, radius: 20, x: 0, y: 10)
    }
}

private struct WeatherStatCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(spacing: 12) {
            SymbolBadge(symbol: symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                Text(value)
                    .font(.system(size: 21, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .roomlyCard(cornerRadius: 18)
    }
}

private struct SmallInfoCard: View {
    let title: String
    let value: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
            }

            Text(value)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(tint == RoomlyTheme.ColorToken.primaryBlue ? Color(red: 0.176, green: 0.369, blue: 0.58) : RoomlyTheme.ColorToken.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tint == RoomlyTheme.ColorToken.primaryBlue ? RoomlyTheme.insightGradient : LinearGradient(colors: [.white, .white], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(RoomlyTheme.ColorToken.border, lineWidth: 1))
        .shadow(color: RoomlyTheme.Shadow.soft, radius: 16, x: 0, y: 8)
    }
}

#Preview {
    NavigationStack {
        WeatherInfoView(weatherViewModel: WeatherViewModel())
    }
}
