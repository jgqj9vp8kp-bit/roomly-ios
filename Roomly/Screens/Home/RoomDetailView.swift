import SwiftUI

struct RoomDetailView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    DetailNavigationBar(title: "Estimated Room Comfort", trailingSymbol: "info.circle") {}
                        .padding(.top, 12)

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
            VStack(spacing: 12) {
                SkeletonCard(height: 168, cornerRadius: 24)
                SkeletonCard(height: 68, cornerRadius: 22)
                SkeletonCard(height: 76, cornerRadius: 22)
                SkeletonCard(height: 350, cornerRadius: 18)
                LoadingStateView(title: "Loading Indoor Comfort", subtitle: "Preparing room and Weather Insights.")
            }
        case .loaded:
            if let dashboard = weatherViewModel.dashboard {
                loadedContent(dashboard)
            } else {
                emptyContent("No Indoor Comfort details are available yet.")
            }
        case .empty(let message):
            emptyContent(message)
        case .failed(let message):
            DataStateView(symbol: "exclamationmark.triangle.fill", title: "Room details unavailable", message: message, actionTitle: "Try Again") {
                Task { await weatherViewModel.reload() }
            }
        }
    }

    private func loadedContent(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 12) {
            indoorCard(dashboard)
            outdoorCard(dashboard)
            comfortStatusCard(dashboard)
            metricRows(dashboard.weatherMetrics)
            comfortTip(dashboard)
        }
    }

    private func indoorCard(_ dashboard: WeatherDashboard) -> some View {
        ZStack(alignment: .topTrailing) {
            RoomlyTheme.blueGradient

            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity([0.10, 0.14, 0.10, 0.08][index]))
                    .frame(width: CGFloat([112, 82, 58, 58][index]))
                    .position(x: CGFloat([272, 296, 29, 58][index]), y: CGFloat([58, 117, 141, 31][index]))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(dashboard.snapshot.indoorEstimate)
                    .font(.system(size: 58, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text("Indoor Estimate")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.918, green: 0.957, blue: 1.0))
            }
            .position(x: 90, y: 92)

            RoomlyWeatherCloud()
                .frame(width: 104, height: 82)
                .position(x: 270, y: 75)

            Image(systemName: "info.circle.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white.opacity(0.86))
                .position(x: 319, y: 137)
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.blue.opacity(0.75), radius: 18, x: 0, y: 10)
    }

    private func outdoorCard(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 14) {
            SymbolBadge(symbol: "cloud.sun.fill", tint: .white, size: 44)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Outdoor Weather")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.76))
                Text("\(dashboard.snapshot.outdoorTemperature) · \(dashboard.snapshot.condition)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 68)
        .background(LinearGradient(colors: [Color(red: 0.424, green: 0.827, blue: 1.0), Color(red: 0.184, green: 0.525, blue: 1.0), RoomlyTheme.ColorToken.primaryBlue], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.blue.opacity(0.45), radius: 16, x: 0, y: 8)
    }

    private func comfortStatusCard(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 12) {
            SymbolBadge(symbol: comfortSymbol(for: dashboard.comfort.level), tint: comfortTint(for: dashboard.comfort.level), size: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text("Comfort Index \(dashboard.comfort.index) · \(dashboard.comfort.level.rawValue)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                Text(dashboard.comfort.roomInsight)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 76)
        .roomlyCard(cornerRadius: 22)
    }

    private func metricRows(_ metrics: [WeatherMetric]) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(metrics.prefix(10)).chunked(into: 2), id: \.first?.id) { row in
                HStack(spacing: 10) {
                    ForEach(row) { metric in
                        GlassMetricCard(metric: metric)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private func comfortTip(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 10) {
            SymbolBadge(symbol: "lightbulb.fill", tint: .white, size: 34, isFilled: true)
            Text(dashboard.comfort.sleepComfort.message)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.204, green: 0.314, blue: 0.42))
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .background(RoomlyTheme.insightGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.863, green: 0.922, blue: 0.98), lineWidth: 1))
        .shadow(color: RoomlyTheme.Shadow.blue.opacity(0.3), radius: 16, x: 0, y: 8)
    }

    private func emptyContent(_ message: String) -> some View {
        DataStateView(symbol: "house.slash.fill", title: "No room details yet", message: message, actionTitle: "Reload") {
            Task { await weatherViewModel.reload() }
        }
    }

    private func comfortSymbol(for level: ComfortLevel) -> String {
        switch level {
        case .excellent, .good:
            "checkmark.seal.fill"
        case .moderate:
            "exclamationmark.circle.fill"
        case .poor:
            "exclamationmark.triangle.fill"
        }
    }

    private func comfortTint(for level: ComfortLevel) -> Color {
        switch level {
        case .excellent, .good:
            RoomlyTheme.ColorToken.green
        case .moderate:
            RoomlyTheme.ColorToken.orange
        case .poor:
            RoomlyTheme.ColorToken.purple
        }
    }
}

#Preview {
    NavigationStack {
        RoomDetailView(weatherViewModel: WeatherViewModel())
    }
}
