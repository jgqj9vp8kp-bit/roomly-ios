import SwiftUI

struct MonthlyOutlookView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    DetailNavigationBar(title: "Monthly Outlook", subtitle: "Planning view", trailingSymbol: "calendar") {}
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
                LoadingStateView(title: "Loading Monthly Outlook", subtitle: "Preparing your planning view.")
            }
        case .loaded:
            if let dashboard = weatherViewModel.dashboard {
                loadedContent(dashboard)
            } else {
                DataStateView(symbol: "calendar.badge.exclamationmark", title: "No Monthly Outlook", message: "No monthly data is available yet.", actionTitle: "Reload") {
                    Task { await weatherViewModel.reload() }
                }
            }
        case .empty(let message):
            DataStateView(symbol: "calendar.badge.exclamationmark", title: "No Monthly Outlook", message: message, actionTitle: "Reload") {
                Task { await weatherViewModel.reload() }
            }
        case .failed(let message):
            DataStateView(symbol: "exclamationmark.triangle.fill", title: "Monthly Outlook unavailable", message: message, actionTitle: "Try Again") {
                Task { await weatherViewModel.reload() }
            }
        }
    }

    private func loadedContent(_ dashboard: WeatherDashboard) -> some View {
        VStack(spacing: 14) {
            monthlySummary
            trendCard

            SectionTitle(title: "Weekly Breakdown")
            weeklyBreakdown(dashboard.outlookWeeks)

            SectionTitle(title: "Best / Worst Days")
            bestWorstDays

            SectionTitle(title: "Comfort Trend")
            comfortTrend

            SectionTitle(title: "Calendar Preview")
            calendarPreview

            monthlyAlerts
        }
    }

    private var monthlySummary: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("May Outlook")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.inkBlue)

                    Text("Slightly warmer · more humid")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }

                Spacer()

                Label("30 days", systemImage: "calendar")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(RoomlyTheme.ColorToken.tileSelected, in: Capsule())
            }

            HStack(spacing: 8) {
                SummaryTile(title: "Avg", value: "18°")
                SummaryTile(title: "Rain", value: "42%")
                SummaryTile(title: "Comfort", value: "82")
                SummaryTile(title: "Wind", value: "Low")
            }
            .frame(height: 70)

            HStack(spacing: 9) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.sun)

                Text("This month will be slightly warmer and more humid than usual.")
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

    private var trendCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Temperature Trend")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)
                    Text("Indoor Estimate follows outdoor patterns")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("+2.4°")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                    Text("vs usual")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
                }
            }

            TrendPlot()
                .frame(height: 126)

            HStack {
                ForEach(["1", "7", "14", "21", "28", "30"], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(red: 0.561, green: 0.651, blue: 0.737))
                    if label != "30" { Spacer() }
                }
            }
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

    private var bestWorstDays: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                InsightDayCard(title: "Best Comfort", date: "May 18", symbol: "checkmark.seal.fill", tint: RoomlyTheme.ColorToken.green)
                InsightDayCard(title: "Warmest Day", date: "May 24", symbol: "sun.max.fill", tint: RoomlyTheme.ColorToken.sun)
            }
            HStack(spacing: 10) {
                InsightDayCard(title: "Rainiest", date: "May 11", symbol: "cloud.rain.fill", tint: RoomlyTheme.ColorToken.primaryBlue)
                InsightDayCard(title: "Coolest Night", date: "May 06", symbol: "moon.fill", tint: RoomlyTheme.ColorToken.purple)
            }
        }
    }

    private var comfortTrend: some View {
        VStack(spacing: 9) {
            ComfortTrendRow(symbol: "arrow.up.forward", title: "Warmer afternoons", subtitle: "Comfort Index improves after noon")
            ComfortTrendRow(symbol: "drop.fill", title: "Higher humidity", subtitle: "Indoor Comfort may feel heavier")
            ComfortTrendRow(symbol: "wind", title: "Calmer evenings", subtitle: "Better window-opening windows")
        }
    }

    private var calendarPreview: some View {
        VStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { row in
                HStack(spacing: 7) {
                    ForEach(0..<7, id: \.self) { column in
                        let day = row * 7 + column + 1
                        CalendarDayCell(day: day, highlighted: [6, 11, 12, 18, 22, 26, 30].contains(day))
                    }
                }
                .frame(height: 44)
            }
        }
        .padding(12)
        .roomlyCard(cornerRadius: 22)
    }

    private var monthlyAlerts: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.green)

            Text("No major weather alerts expected this month.")
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

private struct TrendPlot: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(RoomlyTheme.ColorToken.tile)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.886, green: 0.945, blue: 1), lineWidth: 1))

            VStack(spacing: 35) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(red: 0.851, green: 0.925, blue: 1))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 14)

            TrendArea()
                .fill(LinearGradient(colors: [RoomlyTheme.ColorToken.sky.opacity(0.22), RoomlyTheme.ColorToken.sky.opacity(0.0)], startPoint: .top, endPoint: .bottom))
                .padding(.horizontal, 16)
                .padding(.vertical, 20)

            TrendLine()
                .stroke(RoomlyTheme.ColorToken.primaryBlue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
        }
    }
}

private struct TrendLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: rect.minX, y: rect.maxY * 0.72),
            CGPoint(x: rect.minX + rect.width * 0.24, y: rect.maxY * 0.58),
            CGPoint(x: rect.minX + rect.width * 0.45, y: rect.maxY * 0.48),
            CGPoint(x: rect.minX + rect.width * 0.68, y: rect.maxY * 0.36),
            CGPoint(x: rect.minX + rect.width * 0.87, y: rect.maxY * 0.26),
            CGPoint(x: rect.maxX, y: rect.maxY * 0.22)
        ]
        path.addLines(points)
        return path
    }
}

private struct TrendArea: Shape {
    func path(in rect: CGRect) -> Path {
        var path = TrendLine().path(in: rect)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
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
    let day: Int
    let highlighted: Bool

    var body: some View {
        VStack(spacing: 1) {
            Text("\(day)")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
            Circle()
                .fill(highlighted ? RoomlyTheme.ColorToken.primaryBlue : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(highlighted ? RoomlyTheme.ColorToken.tileSelected : RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        MonthlyOutlookView(weatherViewModel: WeatherViewModel())
    }
}
