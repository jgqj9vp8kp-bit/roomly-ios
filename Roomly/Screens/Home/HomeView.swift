import SwiftUI

struct HomeView: View {
    let temperatureUnit: TemperatureUnit
    let onShowPaywall: () -> Void

    private let snapshot = MockWeatherData.snapshot
    private let columns = [
        GridItem(.flexible(), spacing: RoomlyTheme.Spacing.item),
        GridItem(.flexible(), spacing: RoomlyTheme.Spacing.item)
    ]

    var body: some View {
        ZStack {
            RoomlyBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: RoomlyTheme.Spacing.section) {
                    header
                        .cardEntrance(delay: 0.03)
                    heroCard
                        .cardEntrance(delay: 0.10)
                    metricGrid
                        .cardEntrance(delay: 0.18)
                }
                .padding(.horizontal, RoomlyTheme.Spacing.page)
                .padding(.top, 18)
                .padding(.bottom, 38)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(alignment: .top) {
            ScreenHeader(title: "Roomly", subtitle: "\(snapshot.location) • \(snapshot.updatedAt)")

            Button(action: onShowPaywall) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black.opacity(0.82))
                    .frame(width: 44, height: 44)
                    .background(RoomlyTheme.premium, in: Circle())
                    .shadow(color: .cyan.opacity(0.22), radius: 14, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Roomly Premium")
        }
    }

    private var heroCard: some View {
        VStack(spacing: 24) {
            VStack(spacing: 18) {
                ComfortGauge(value: snapshot.comfortIndex, size: 178, label: "Comfort Index")

                VStack(alignment: .leading, spacing: 10) {
                    Text("Indoor Estimate")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.64))

                    Text(indoorEstimate)
                        .font(.system(size: 78, weight: .thin, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.72)
                        .contentTransition(.numericText())

                    Label(snapshot.condition, systemImage: "sparkle.magnifyingglass")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 14) {
                CompactValue(symbol: "location.fill", title: "Local Weather", value: localWeatherTemperature)
                CompactValue(symbol: "humidity.fill", title: "Humidity", value: snapshot.humidity)
            }

            TemperatureProgress(value: MockWeatherData.indoorEstimateCelsius, unit: temperatureUnit)
        }
        .padding(24)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: RoomlyTheme.Radius.hero, style: .continuous)
                    .fill(RoomlyTheme.aurora.opacity(0.72))

                RoundedRectangle(cornerRadius: RoomlyTheme.Radius.hero, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.52))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: RoomlyTheme.Radius.hero, style: .continuous)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .cyan.opacity(0.16), radius: 30, x: 0, y: 20)
    }

    private var metricGrid: some View {
        VStack(spacing: 14) {
            SectionTitle(title: "Room Conditions", symbol: "dial.high.fill")

            LazyVGrid(columns: columns, spacing: RoomlyTheme.Spacing.item) {
                ForEach(Array(MockWeatherData.metrics(for: temperatureUnit).enumerated()), id: \.element.id) { index, metric in
                    GlassMetricCard(metric: metric)
                        .cardEntrance(delay: 0.22 + Double(index) * 0.04)
                }
            }
        }
    }

    private var indoorEstimate: String {
        temperatureUnit.formatted(celsius: MockWeatherData.indoorEstimateCelsius)
    }

    private var localWeatherTemperature: String {
        temperatureUnit.formatted(celsius: MockWeatherData.outdoorTemperatureCelsius)
    }
}

private struct CompactValue: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.cyan)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.10), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))

                Text(value)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 0)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.09), in: RoundedRectangle(cornerRadius: RoomlyTheme.Radius.control, style: .continuous))
    }
}

private struct TemperatureProgress: View {
    let value: Int
    let unit: TemperatureUnit

    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Indoor Estimate range")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.56))

                Spacer()

                Text(unit.formatted(celsius: value))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.82))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))

                    Capsule()
                        .fill(RoomlyTheme.premium)
                        .frame(width: proxy.size.width * progress)
                        .shadow(color: RoomlyTheme.ColorToken.cyan.opacity(0.30), radius: 8, x: 0, y: 0)
                }
            }
            .frame(height: 8)
        }
        .padding(15)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: RoomlyTheme.Radius.control, style: .continuous))
        .onAppear {
            progress = 0
            withAnimation(.easeOut(duration: 0.9).delay(0.25)) {
                progress = min(max(CGFloat(value - 12) / 18, 0.12), 0.92)
            }
        }
    }
}

#Preview {
    HomeView(temperatureUnit: .celsius, onShowPaywall: {})
        .preferredColorScheme(.dark)
}
