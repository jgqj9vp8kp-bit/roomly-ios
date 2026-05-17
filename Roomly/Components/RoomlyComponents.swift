import SwiftUI

struct ScreenHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GlassMetricCard: View {
    let metric: WeatherMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SymbolBadge(symbol: metric.symbol, tint: metric.tint, size: 36)
                Spacer()
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 6) {
                Text(metric.value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.76)
                    .lineLimit(1)

                Text(metric.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.86))
                    .lineLimit(2)

                Text(metric.caption)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.52))
                    .lineLimit(2)
            }
        }
        .padding(RoomlyTheme.Spacing.card)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .glassCard(cornerRadius: 22)
    }
}

struct SectionTitle: View {
    let title: String
    let symbol: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(.cyan)

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PremiumButton: View {
    let title: String
    var symbol: String = "crown.fill"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                Text(title)
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            .foregroundStyle(.black.opacity(0.82))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoomlyTheme.premium, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: RoomlyTheme.ColorToken.cyan.opacity(0.25), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct SymbolBadge: View {
    let symbol: String
    var tint: Color = .cyan
    var size: CGFloat = 38

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.14), in: Circle())
    }
}

struct ComfortGauge: View {
    let value: Int
    var size: CGFloat = 116
    var label: String = "Comfort"

    @State private var progress: CGFloat = 0
    @State private var glows = false

    var body: some View {
        ZStack {
            Circle()
                .fill(RoomlyTheme.premium)
                .frame(width: size * 0.78, height: size * 0.78)
                .blur(radius: 28)
                .opacity(glows ? 0.34 : 0.18)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glows)

            Circle()
                .stroke(Color.white.opacity(0.13), lineWidth: size * 0.09)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    RoomlyTheme.premium,
                    style: StrokeStyle(lineWidth: size * 0.09, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: RoomlyTheme.ColorToken.cyan.opacity(0.38), radius: 10, x: 0, y: 0)

            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            progress = 0
            withAnimation(.easeOut(duration: 1.05)) {
                progress = CGFloat(value) / 100
            }
            glows = true
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Comfort Index \(value)")
    }
}

struct AnimatedCardModifier: ViewModifier {
    var delay: Double = 0
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 14)
            .onAppear {
                withAnimation(.easeOut(duration: 0.45).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func cardEntrance(delay: Double = 0) -> some View {
        modifier(AnimatedCardModifier(delay: delay))
    }
}

struct TemperaturePill: View {
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "thermometer.medium")
                .font(.system(size: 34, weight: .thin))
                .foregroundStyle(RoomlyTheme.premium)

            Text(value)
                .font(.system(size: 38, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.58))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .glassCard(cornerRadius: 28)
    }
}

#Preview("Components") {
    ZStack {
        RoomlyBackground()
        VStack(spacing: 16) {
            ScreenHeader(title: "Roomly", subtitle: "Premium indoor comfort")
            ComfortGauge(value: 86)
            PremiumButton(title: "Start Premium") {}
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
