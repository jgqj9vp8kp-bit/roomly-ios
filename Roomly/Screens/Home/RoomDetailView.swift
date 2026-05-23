import SwiftUI

struct RoomDetailView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    DetailNavigationBar(title: "Estimated Room Comfort", trailingSymbol: "info.circle", trailingAction: {}, leadingAction: onBack)
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
            if weatherViewModel.roomSettings.hasCustomValues {
                roomSettingsAppliedCard(weatherViewModel.roomSettings)
            }
            outdoorCard(dashboard)
            comfortStatusCard(dashboard)
            metricRows(dashboard.weatherMetrics)
            comfortTip(dashboard)
        }
    }

    private func indoorCard(_ dashboard: WeatherDashboard) -> some View {
        ZStack(alignment: .topTrailing) {
            IndoorApartmentPhotoBackground()

            LinearGradient(
                colors: [
                    Color(red: 0.051, green: 0.451, blue: 0.957).opacity(0.43),
                    Color(red: 0.027, green: 0.337, blue: 0.847).opacity(0.57),
                    Color(red: 0.016, green: 0.149, blue: 0.373).opacity(0.77)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
                .padding(1)

            Circle()
                .fill(.white.opacity(0.095))
                .frame(width: 112, height: 112)
                .position(x: 272, y: 56)

            Circle()
                .fill(RoomlyTheme.ColorToken.primaryBlue.opacity(0.21))
                .frame(width: 82, height: 82)
                .position(x: 295, y: 117)

            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 58, height: 58)
                .position(x: 29, y: 139)

            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 58, height: 58)
                .position(x: 59, y: 31)

            VStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { index in
                    IndoorAirflowLine()
                        .stroke(.white.opacity([0.10, 0.09, 0.08, 0.07][index]), style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
                        .frame(height: 18)
                }
            }
            .frame(width: 318)
            .position(x: 177, y: 82)

            RoomlyWeatherCloud()
                .frame(width: 104, height: 84)
                .position(x: 270, y: 72)

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.72)
                    .frame(width: 34, height: 34)

                Circle()
                    .stroke(.white.opacity(0.22), lineWidth: 1)
                    .frame(width: 34, height: 34)

                Image(systemName: "info")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.92))
            }
            .position(x: 319, y: 137)

            VStack(alignment: .leading, spacing: 2) {
                Text(dashboard.snapshot.indoorEstimate)
                    .font(.system(size: 58, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.26), radius: 8, x: 0, y: 3)

                Text("Indoor Estimate")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.936, green: 0.968, blue: 1.0))
                    .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 2)
            }
            .position(x: 90, y: 92)
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.blue.opacity(0.75), radius: 18, x: 0, y: 10)
    }

    private func roomSettingsAppliedCard(_ settings: RoomSettings) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Room Settings Applied")

            Text("Indoor Estimate is calculated using local weather and your room settings.")
                .font(.system(size: 13, weight: .semibold))
                .lineSpacing(2)
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                roomSettingRow(
                    symbol: "snowflake",
                    title: "AC",
                    value: controlValue(isOn: settings.isACOn, celsiusValue: settings.acTemperatureCelsius)
                )

                roomSettingRow(
                    symbol: "flame.fill",
                    title: "Heater",
                    value: controlValue(isOn: settings.isHeaterOn, celsiusValue: settings.heaterTemperatureCelsius)
                )

                roomSettingRow(
                    symbol: "fan.fill",
                    title: "Fan",
                    value: fanValue(isOn: settings.isFanOn, celsiusValue: settings.fanCoolingEffectCelsius)
                )

                roomSettingRow(
                    symbol: "house.fill",
                    title: "Insulation",
                    value: settings.insulationType.title
                )
            }
        }
        .padding(16)
        .roomlyCard(cornerRadius: 22)
    }

    private func roomSettingRow(symbol: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            SymbolBadge(symbol: symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 34)

            Text(title)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func controlValue(isOn: Bool, celsiusValue: Double?) -> String {
        guard isOn else { return "Off" }
        guard let celsiusValue else { return "On" }
        return "On · \(weatherViewModel.temperatureUnit.formatted(celsius: celsiusValue))"
    }

    private func fanValue(isOn: Bool, celsiusValue: Double?) -> String {
        guard isOn else { return "Off" }
        guard let celsiusValue else { return "On" }
        return "On · \(Int(weatherViewModel.temperatureUnit.displayDelta(celsius: celsiusValue).rounded()))\(weatherViewModel.temperatureUnit.shortTitle) cooling"
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

private struct IndoorApartmentPhotoBackground: View {
    var body: some View {
        Image("IndoorRoomPhoto")
            .resizable()
            .scaledToFill()
    }
}

private struct IndoorAirflowLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let y = rect.midY

        path.move(to: CGPoint(x: rect.minX, y: y))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.38, y: y - 1),
            control1: CGPoint(x: rect.width * 0.12, y: y - 8),
            control2: CGPoint(x: rect.width * 0.26, y: y + 8)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.68, y: y),
            control1: CGPoint(x: rect.width * 0.48, y: y - 8),
            control2: CGPoint(x: rect.width * 0.57, y: y + 8)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: y - 1),
            control1: CGPoint(x: rect.width * 0.78, y: y - 8),
            control2: CGPoint(x: rect.width * 0.90, y: y + 8)
        )

        return path
    }
}

#Preview {
    NavigationStack {
        RoomDetailView(weatherViewModel: WeatherViewModel())
    }
}
