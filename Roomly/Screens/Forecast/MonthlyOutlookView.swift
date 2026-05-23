import SwiftUI

struct MonthlyOutlookView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    DetailNavigationBar(title: "Comfort Outlook", subtitle: "7-day planning view", trailingSymbol: "calendar", trailingAction: {})
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
            VStack(spacing: 14) {
                SkeletonCard(height: 204, cornerRadius: 24)
                SkeletonCard(height: 232, cornerRadius: 24)
                SkeletonCard(height: 222, cornerRadius: 20)
                LoadingStateView(title: "Loading Comfort Outlook", subtitle: "Preparing your planning view.")
            }
        case .loaded:
            if let dashboard = weatherViewModel.dashboard {
                loadedContent(dashboard)
            } else {
                DataStateView(symbol: "calendar.badge.exclamationmark", title: "No Comfort Outlook", message: "No comfort outlook is available yet.", actionTitle: "Reload") {
                    Task { await weatherViewModel.reload() }
                }
            }
        case .empty(let message):
            DataStateView(symbol: "calendar.badge.exclamationmark", title: "No Comfort Outlook", message: message, actionTitle: "Reload") {
                Task { await weatherViewModel.reload() }
            }
        case .failed(let message):
            DataStateView(symbol: "exclamationmark.triangle.fill", title: "Comfort Outlook unavailable", message: message, actionTitle: "Try Again") {
                Task { await weatherViewModel.reload() }
            }
        }
    }

    private func loadedContent(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 14) {
            monthlySummary(dashboard)
            trendCard(dashboard)

            SectionTitle(title: "Weekly Breakdown")
            weeklyBreakdown(dashboard.outlookWeeks)

            SectionTitle(title: "Best / Worst Days")
            bestWorstDays(dashboard)

            SectionTitle(title: "Comfort Trend")
            comfortTrend(dashboard)

            SectionTitle(title: "Calendar Preview", trailing: "Month")
            calendarPreview(dashboard)

            monthlyAlerts(dashboard)
        }
    }

    private func monthlySummary(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("7-Day Comfort Outlook")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.inkBlue)

                    Text(dashboard.comfort.outlookSummary)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }

                Spacer()

                Label("7 days", systemImage: "calendar")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(RoomlyTheme.ColorToken.tileSelected, in: Capsule())
            }

            HStack(spacing: 8) {
                SummaryTile(title: "Avg", value: weatherViewModel.temperatureUnit.degreeString(celsius: Double(dashboard.comfort.averageHighCelsius)))
                SummaryTile(title: "Rain", value: "\(dashboard.comfort.peakRainChance)%")
                SummaryTile(title: "Comfort", value: "\(dashboard.comfort.index)")
                SummaryTile(title: "Wind", value: dashboard.comfort.windSummary)
            }
            .frame(height: 70)

            HStack(spacing: 9) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.sun)

                Text(dashboard.comfort.weeklyTrendInsight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.inkBlue)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(RoomlyTheme.ColorToken.surfaceBlue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 0.867, green: 0.937, blue: 1), lineWidth: 1))
        }
        .padding(16)
        .roomlyCard(cornerRadius: 24, stroke: Color(red: 0.882, green: 0.941, blue: 1))
    }

    private func trendCard(_ dashboard: WeatherDashboard) -> some View {
        let trend = TemperatureTrend(daily: dashboard.daily)

        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Temperature Trend")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)
                    Text(trend.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(trend.title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(trend.tint)
                    Text(trend.deltaText)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
                }
            }

            TrendPlot(trend: trend)
                .frame(height: 126)

            HStack {
                ForEach(Array(trend.dayLabels.enumerated()), id: \.offset) { index, label in
                    VStack(spacing: 2) {
                        Text(label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(red: 0.561, green: 0.651, blue: 0.737))

                        Text(index < trend.temperatureLabels.count ? trend.temperatureLabels[index] : "")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(index == trend.dayLabels.count - 1 ? trend.tint : RoomlyTheme.ColorToken.tertiaryInk)
                    }
                    .frame(width: 28)

                    if index != trend.dayLabels.count - 1 {
                        Spacer()
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: trend.symbol)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(trend.tint)

                Text(trend.insight)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .lineLimit(2)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(trend.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(16)
        .roomlyCard(cornerRadius: 24, stroke: Color(red: 0.882, green: 0.941, blue: 1))
    }

    private func weeklyBreakdown(_ weeks: [OutlookWeek]) -> some View {
        VStack(spacing: 10) {
            ForEach(weeks.chunked(into: 2), id: \.first?.id) { row in
                HStack(spacing: 10) {
                    ForEach(row) { week in
                        OutlookWeekCard(week: week)
                    }
                }
                .frame(height: 106)
            }
        }
    }

    private func bestWorstDays(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                InsightDayCard(title: "Best Comfort", date: dashboard.comfort.bestComfortDay, symbol: "checkmark.seal.fill", tint: RoomlyTheme.ColorToken.green)
                InsightDayCard(title: "Warmest Day", date: dashboard.comfort.warmestDay, symbol: "sun.max.fill", tint: RoomlyTheme.ColorToken.sun)
            }
            HStack(spacing: 10) {
                InsightDayCard(title: "Rainiest", date: dashboard.comfort.rainiestDay, symbol: "cloud.rain.fill", tint: RoomlyTheme.ColorToken.primaryBlue)
                InsightDayCard(title: "Coolest Night", date: dashboard.comfort.coolestNight, symbol: "moon.fill", tint: RoomlyTheme.ColorToken.purple)
            }
        }
    }

    private func comfortTrend(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 9) {
            ComfortTrendRow(symbol: "arrow.up.forward", title: "Comfort pattern", subtitle: dashboard.comfort.weeklyTrendInsight)
            ComfortTrendRow(symbol: "drop.fill", title: dashboard.comfort.humidityComfort.title, subtitle: dashboard.comfort.humidityComfort.message)
            ComfortTrendRow(symbol: "wind", title: dashboard.comfort.windRisk.title, subtitle: dashboard.comfort.windRisk.message)
        }
    }

    private func calendarPreview(_ dashboard: WeatherDashboard) -> some View {
        let days = CalendarPreviewDay.make(from: dashboard.daily)
        let rows = days.chunked(into: 7)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                CalendarLegendItem(label: "Best", color: RoomlyTheme.ColorToken.green)
                CalendarLegendItem(label: "Warm", color: RoomlyTheme.ColorToken.orange)
                CalendarLegendItem(label: "Rain", color: RoomlyTheme.ColorToken.primaryBlue)
                CalendarLegendItem(label: "Steady", color: RoomlyTheme.ColorToken.purple)
            }

            VStack(spacing: 8) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, rowDays in
                    HStack(spacing: 7) {
                        ForEach(rowDays) { day in
                            CalendarDayCell(day: day)
                        }
                    }
                    .frame(height: 72)
                }
            }

            Text("First 7 days use forecast data. Later days are projected from the same pattern.")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
        }
        .padding(14)
        .roomlyCard(cornerRadius: 22)
    }

    private func monthlyAlerts(_ dashboard: WeatherDashboard) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.green)

            Text("Outlook is based on available 7-day forecast data, not a precise 30-day forecast. \(dashboard.comfort.rainRisk.message)")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .roomlyCard(cornerRadius: 18)
    }
}

private struct SummaryTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.inkBlue)
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 0.878, green: 0.941, blue: 1), lineWidth: 1))
    }
}

private struct TemperatureTrend {
    let values: [Int]
    let dayLabels: [String]

    init(daily: [DailyForecast]) {
        let usableDays = daily.isEmpty ? MockWeatherData.daily : daily
        values = usableDays.map(\.high)
        dayLabels = usableDays.map { item in
            item.day == "Today" ? "Now" : item.day
        }
    }

    var title: String {
        switch direction {
        case .warming:
            "Warming"
        case .cooling:
            "Cooling"
        case .stable:
            "Stable"
        }
    }

    var subtitle: String {
        "Highs across the available 7-day forecast"
    }

    var deltaText: String {
        guard let first = values.first, let last = values.last else {
            return "No trend"
        }

        let delta = last - first
        if delta == 0 {
            return "0° change"
        }
        return "\(delta > 0 ? "+" : "")\(delta)° by end"
    }

    var insight: String {
        switch direction {
        case .warming:
            "Temperatures trend upward later in the forecast."
        case .cooling:
            "Temperatures ease cooler later in the forecast."
        case .stable:
            "Temperatures stay fairly steady across the forecast."
        }
    }

    var symbol: String {
        switch direction {
        case .warming:
            "arrow.up.right"
        case .cooling:
            "arrow.down.right"
        case .stable:
            "arrow.right"
        }
    }

    var tint: Color {
        switch direction {
        case .warming:
            RoomlyTheme.ColorToken.orange
        case .cooling:
            RoomlyTheme.ColorToken.primaryBlue
        case .stable:
            RoomlyTheme.ColorToken.green
        }
    }

    var temperatureLabels: [String] {
        values.map { "\($0)°" }
    }

    var minValue: Int {
        values.min() ?? 0
    }

    var maxValue: Int {
        values.max() ?? 1
    }

    private var direction: Direction {
        guard let first = values.first, let last = values.last else {
            return .stable
        }

        let delta = last - first
        if delta >= 3 {
            return .warming
        } else if delta <= -3 {
            return .cooling
        } else {
            return .stable
        }
    }

    private enum Direction {
        case warming
        case cooling
        case stable
    }
}

private struct TrendPlot: View {
    let trend: TemperatureTrend

    var body: some View {
        GeometryReader { proxy in
            let rect = CGRect(
                x: 16,
                y: 20,
                width: max(1, proxy.size.width - 32),
                height: max(1, proxy.size.height - 40)
            )
            let points = plotPoints(in: rect)

            ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(RoomlyTheme.ColorToken.tile)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.886, green: 0.945, blue: 1), lineWidth: 1))

                VStack(spacing: rect.height / 2) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(red: 0.851, green: 0.925, blue: 1))
                        .frame(height: 1)
                }
            }
                .padding(.horizontal, 14)

                trendArea(points: points, baseline: rect.maxY)
                    .fill(LinearGradient(colors: [trend.tint.opacity(0.24), trend.tint.opacity(0.0)], startPoint: .top, endPoint: .bottom))

                trendLine(points: points)
                    .stroke(trend.tint, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))

                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(index == points.count - 1 ? trend.tint : .white)
                        .frame(width: index == points.count - 1 ? 9 : 7, height: index == points.count - 1 ? 9 : 7)
                        .overlay(Circle().stroke(trend.tint, lineWidth: 2))
                        .position(point)
                }
            }
        }
    }

    private func plotPoints(in rect: CGRect) -> [CGPoint] {
        guard !trend.values.isEmpty else { return [] }
        let span = max(1, Double(trend.maxValue - trend.minValue))
        let xStep = trend.values.count == 1 ? 0 : rect.width / CGFloat(trend.values.count - 1)

        return trend.values.enumerated().map { index, value in
            let normalized = (Double(value - trend.minValue) / span)
            let y = rect.maxY - CGFloat(normalized) * rect.height
            return CGPoint(x: rect.minX + CGFloat(index) * xStep, y: y)
        }
    }

    private func trendLine(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        path.addLines(points)
        return path
    }

    private func trendArea(points: [CGPoint], baseline: CGFloat) -> Path {
        var path = trendLine(points: points)
        guard let first = points.first, let last = points.last else { return path }
        path.addLine(to: CGPoint(x: last.x, y: baseline))
        path.addLine(to: CGPoint(x: first.x, y: baseline))
        path.closeSubpath()
        return path
    }
}

private struct OutlookWeekCard: View {
    let week: OutlookWeek

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SymbolBadge(symbol: week.symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 34)
            Text(week.title)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
            Text("\(week.temperature) · \(week.comfort)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .roomlyCard(cornerRadius: 20)
    }
}

private struct InsightDayCard: View {
    let title: String
    let date: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 9) {
            SymbolBadge(symbol: symbol, tint: tint, size: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                Text(date)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)
            }
            Spacer()
        }
        .padding(.horizontal, 11)
        .frame(maxWidth: .infinity, minHeight: 76)
        .roomlyCard(cornerRadius: 18)
    }
}

private struct ComfortTrendRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            SymbolBadge(symbol: symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 34)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 58)
        .roomlyCard(cornerRadius: 18)
    }
}

private struct CalendarDayCell: View {
    let day: CalendarPreviewDay

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Text(day.label)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(day.isPlaceholder ? RoomlyTheme.ColorToken.tertiaryInk : RoomlyTheme.ColorToken.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if !day.isPlaceholder {
                    Circle()
                        .fill(day.status.color)
                        .frame(width: 5, height: 5)
                }
            }

            Image(systemName: day.symbol)
                .font(.system(size: 14, weight: .bold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(day.status.color, RoomlyTheme.ColorToken.sun, RoomlyTheme.ColorToken.sky)
                .frame(height: 16)
                .opacity(day.isPlaceholder ? 0.0 : 1.0)

            Text(day.temperatureText)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(day.isPlaceholder ? .clear : RoomlyTheme.ColorToken.secondaryInk)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(day.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(day.status.color.opacity(day.isPlaceholder ? 0.0 : 0.18), lineWidth: 1)
        )
    }
}

private struct CalendarLegendItem: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(RoomlyTheme.ColorToken.tile, in: Capsule())
    }
}

private struct CalendarPreviewDay: Identifiable {
    let id = UUID()
    let label: String
    let symbol: String
    let high: Int?
    let low: Int?
    let status: CalendarPreviewStatus
    let isPlaceholder: Bool

    var temperatureText: String {
        guard let high, let low else {
            return "--"
        }
        return "\(high)°/\(low)°"
    }

    var background: Color {
        isPlaceholder ? RoomlyTheme.ColorToken.tile.opacity(0.72) : status.color.opacity(0.10)
    }

    static func make(from daily: [DailyForecast]) -> [CalendarPreviewDay] {
        let source = daily.isEmpty ? MockWeatherData.daily : daily
        let highs = source.map(\.high)
        let maxHigh = highs.max() ?? 0
        let rainChances = source.map { Int($0.chance.replacingOccurrences(of: "%", with: "")) ?? 0 }
        let minRain = rainChances.min() ?? 0

        return (0..<35).map { index in
            let item = source[index % source.count]
            let rainChance = Int(item.chance.replacingOccurrences(of: "%", with: "")) ?? 0
            let status = CalendarPreviewStatus.status(
                high: item.high,
                maxHigh: maxHigh,
                rainChance: rainChance,
                minRain: minRain
            )

            return CalendarPreviewDay(
                label: label(for: index, item: item),
                symbol: item.symbol,
                high: projectedTemperature(item.high, dayIndex: index),
                low: projectedTemperature(item.low, dayIndex: index),
                status: status,
                isPlaceholder: false
            )
        }
    }

    private static func label(for index: Int, item: DailyForecast) -> String {
        if index == 0 {
            return "Now"
        }
        if index < 7 {
            return item.day
        }
        return "\(index + 1)"
    }

    private static func projectedTemperature(_ value: Int, dayIndex: Int) -> Int {
        guard dayIndex >= 7 else { return value }
        let drift = ((dayIndex / 7) % 3) - 1
        return value + drift
    }
}

private enum CalendarPreviewStatus {
    case best
    case warm
    case rain
    case steady

    var color: Color {
        switch self {
        case .best:
            RoomlyTheme.ColorToken.green
        case .warm:
            RoomlyTheme.ColorToken.orange
        case .rain:
            RoomlyTheme.ColorToken.primaryBlue
        case .steady:
            RoomlyTheme.ColorToken.purple
        }
    }

    static func status(high: Int, maxHigh: Int, rainChance: Int, minRain: Int) -> CalendarPreviewStatus {
        if rainChance >= 50 {
            return .rain
        }

        if high >= maxHigh - 1 {
            return .warm
        }

        if rainChance <= minRain + 5 {
            return .best
        }

        return .steady
    }
}

#Preview {
    NavigationStack {
        MonthlyOutlookView(weatherViewModel: WeatherViewModel())
    }
}
