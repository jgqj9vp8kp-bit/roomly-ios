import SwiftUI

struct ForecastView: View {
    private let hourly = MockWeatherData.hourly
    private let daily = MockWeatherData.daily

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: RoomlyTheme.Spacing.section) {
                    ScreenHeader(title: "Forecast", subtitle: "Local Weather outlook with mock indoor comfort trends")
                        .cardEntrance(delay: 0.04)
                    hourlyForecast
                        .cardEntrance(delay: 0.10)
                    dailyForecast
                        .cardEntrance(delay: 0.16)
                    indoorTrend
                        .cardEntrance(delay: 0.22)
                }
                .padding(.horizontal, RoomlyTheme.Spacing.page)
                .padding(.top, 18)
                .padding(.bottom, 38)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var hourlyForecast: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Next Hours", symbol: "clock.fill")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(hourly.enumerated()), id: \.element.id) { index, item in
                        HourlyForecastCard(item: item)
                            .cardEntrance(delay: 0.08 + Double(index) * 0.04)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var dailyForecast: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Six Day View", symbol: "calendar")

            VStack(spacing: 10) {
                ForEach(Array(daily.enumerated()), id: \.element.id) { index, item in
                    DailyForecastRow(item: item)
                        .cardEntrance(delay: 0.10 + Double(index) * 0.035)
                }
            }
            .padding(14)
            .glassCard(cornerRadius: 26, glow: true)
        }
    }

    private var indoorTrend: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Indoor Trend", symbol: "waveform.path.ecg")

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array([58, 76, 70, 88, 82, 91, 86].enumerated()), id: \.offset) { index, value in
                    ForecastBar(value: value, delay: Double(index) * 0.05)
                }
            }
            .frame(height: 118)

            Text("Comfort remains in the ideal range through the evening with a small humidity lift after midnight.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.64))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .glassCard(cornerRadius: 26)
    }
}

private struct ForecastBar: View {
    let value: Int
    let delay: Double

    @State private var height: CGFloat = 0

    var body: some View {
        Capsule(style: .continuous)
            .fill(RoomlyTheme.premium)
            .frame(height: height)
            .frame(maxWidth: .infinity, alignment: .bottom)
            .opacity(value > 80 ? 1 : 0.62)
            .onAppear {
                height = 0
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(delay)) {
                    height = CGFloat(value)
                }
            }
    }
}

private struct HourlyForecastCard: View {
    let item: HourlyForecast

    var body: some View {
        VStack(spacing: 12) {
            Text(item.time)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.60))

            Image(systemName: item.symbol)
                .font(.system(size: 24, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.cyan)
                .frame(height: 28)

            Text(item.temperature)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(item.chance)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.48))
        }
        .frame(width: 82, height: 138)
        .glassCard(cornerRadius: 24, borderOpacity: 0.14)
    }
}

private struct DailyForecastRow: View {
    let item: DailyForecast

    var body: some View {
        HStack(spacing: 14) {
            Text(item.day)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 54, alignment: .leading)

            Image(systemName: item.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.cyan)
                .frame(width: 28)

            Text(item.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.66))

            Spacer()

            Text("\(item.low)°")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.50))

            TemperatureRange(low: item.low, high: item.high)

            Text("\(item.high)°")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.vertical, 9)
    }
}

private struct TemperatureRange: View {
    let low: Int
    let high: Int

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let lowOffset = CGFloat(max(low - 6, 0)) / 18 * width
            let rangeWidth = CGFloat(max(high - low, 2)) / 18 * width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))

                Capsule()
                    .fill(RoomlyTheme.premium)
                    .frame(width: min(rangeWidth, width - lowOffset))
                    .offset(x: min(lowOffset, width * 0.72))
            }
        }
        .frame(width: 76, height: 6)
    }
}

#Preview {
    ForecastView()
        .preferredColorScheme(.dark)
}
