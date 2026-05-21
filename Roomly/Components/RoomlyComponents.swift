import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum HapticFeedback {
    static func light() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    static func selection() {
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}

enum ComfortVisuals {
    static func tint(for level: ComfortLevel) -> Color {
        switch level {
        case .excellent:
            RoomlyTheme.ColorToken.green
        case .good:
            RoomlyTheme.ColorToken.primaryBlue
        case .moderate:
            RoomlyTheme.ColorToken.orange
        case .poor:
            RoomlyTheme.ColorToken.red
        }
    }

    static func gradient(for level: ComfortLevel) -> LinearGradient {
        switch level {
        case .excellent:
            LinearGradient(colors: [RoomlyTheme.ColorToken.green, RoomlyTheme.ColorToken.sky, RoomlyTheme.ColorToken.primaryBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .good:
            RoomlyTheme.blueGradient
        case .moderate:
            RoomlyTheme.orangeGradient
        case .poor:
            LinearGradient(colors: [RoomlyTheme.ColorToken.red, RoomlyTheme.ColorToken.orange, RoomlyTheme.ColorToken.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct ScreenHeader: View {
    let title: String
    let subtitle: String
    var trailingSymbol: String?
    var trailingAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            if let trailingSymbol, let trailingAction {
                IconButton(symbol: trailingSymbol, action: trailingAction)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DetailNavigationBar: View {
    let title: String
    var subtitle: String?
    var trailingSymbol: String?
    var trailingAction: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 12) {
            IconButton(symbol: "chevron.left") {
                dismiss()
            }

            VStack(alignment: subtitle == nil ? .center : .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: subtitle == nil ? 18 : 20, weight: .bold, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }
            }
            .frame(maxWidth: .infinity, alignment: subtitle == nil ? .center : .leading)

            if let trailingSymbol, let trailingAction {
                IconButton(symbol: trailingSymbol, action: trailingAction)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .frame(height: 44)
    }
}

struct SectionTitle: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
            }
        }
    }
}

struct IconButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                .frame(width: 40, height: 40)
                .background(RoomlyTheme.ColorToken.tile, in: Circle())
                .overlay(Circle().stroke(RoomlyTheme.ColorToken.border, lineWidth: 1))
                .shadow(color: RoomlyTheme.Shadow.soft, radius: 10, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct SymbolBadge: View {
    let symbol: String
    var tint: Color = RoomlyTheme.ColorToken.primaryBlue
    var size: CGFloat = 38
    var isFilled = false

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.45, weight: .bold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(isFilled ? .white : tint)
            .frame(width: size, height: size)
            .background(isFilled ? tint : tint.opacity(0.12), in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}

struct PremiumButton: View {
    let title: String
    var symbol: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            HStack(spacing: 10) {
                Text(title)
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .font(.system(size: 21, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(RoomlyTheme.ctaGradient, in: RoundedRectangle(cornerRadius: RoomlyTheme.Radius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: RoomlyTheme.Radius.button, style: .continuous)
                    .stroke(.white.opacity(0.26), lineWidth: 1)
            )
            .shadow(color: RoomlyTheme.Shadow.blue, radius: 24, x: 0, y: 12)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.985))
    }
}

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct SecondaryPillButton: View {
    let title: String
    var symbol: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            Label(title, systemImage: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.94), in: Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct DashboardWeatherCard: View {
    let title: String
    let subtitle: String
    let value: String
    let footnote: String
    let symbol: String
    let gradient: LinearGradient

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.14))
                .frame(width: 172, height: 172)
                .offset(x: 52, y: -34)

            Circle()
                .fill(.black.opacity(0.08))
                .frame(width: 104, height: 104)
                .offset(x: 38, y: 88)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text(value)
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text(footnote)
                        .font(.system(size: 12, weight: .semibold))
                        .lineSpacing(2)
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 190, alignment: .leading)

                Spacer()

                Image(systemName: symbol)
                    .font(.system(size: 64, weight: .bold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, RoomlyTheme.ColorToken.sun)
                    .padding(.top, 28)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, minHeight: 212, alignment: .leading)
        .background(gradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: RoomlyTheme.Shadow.blue, radius: 24, x: 0, y: 14)
    }
}

struct ComfortGaugeDashboardCard: View {
    let dashboard: WeatherDashboard
    let unit: TemperatureUnit

    var body: some View {
        ZStack {
            ComfortVisuals.gradient(for: dashboard.comfort.level)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
                .padding(1)

            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Indoor Comfort")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text(dashboard.comfort.level.rawValue)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.opacity)

                    Text("Indoor Estimate")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    if dashboard.usesCustomRoomSettings {
                        Text("Using your room settings")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white.opacity(0.86))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.14), in: Capsule())
                    }

                    Text(dashboard.comfort.roomInsight)
                        .font(.system(size: 12, weight: .semibold))
                        .lineSpacing(2)
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ComfortRadialGauge(
                    value: dashboard.comfort.index,
                    level: dashboard.comfort.level,
                    centerText: "\(dashboard.comfort.index)",
                    caption: dashboard.snapshot.indoorEstimate
                )
                .frame(width: 128, height: 128)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, minHeight: 212)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: ComfortVisuals.tint(for: dashboard.comfort.level).opacity(0.26), radius: 26, x: 0, y: 15)
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: dashboard.comfort.index)
    }
}

struct ComfortRadialGauge: View {
    let value: Int
    let level: ComfortLevel
    let centerText: String
    let caption: String

    @State private var animatedProgress = 0.0
    @State private var glowPulse = false

    private var progress: Double {
        min(1, max(0, Double(value) / 100))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.12))
                .blur(radius: glowPulse ? 9 : 5)
                .scaleEffect(glowPulse ? 1.05 : 0.96)

            Circle()
                .stroke(.white.opacity(0.20), lineWidth: 13)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [.white.opacity(0.95), ComfortVisuals.tint(for: level).opacity(0.92), .white.opacity(0.85)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 13, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: .white.opacity(0.32), radius: 8, x: 0, y: 0)

            VStack(spacing: 1) {
                Text(centerText)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text(caption)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.80))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.85, dampingFraction: 0.86).delay(0.12)) {
                animatedProgress = progress
            }

            withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
        .onChange(of: value) { _, _ in
            withAnimation(.spring(response: 0.72, dampingFraction: 0.86)) {
                animatedProgress = progress
            }
        }
    }
}

struct DailyInsightCard: View {
    let symbol: String
    let title: String
    let message: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SymbolBadge(symbol: symbol, tint: tint, size: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(message)
                    .font(.system(size: 11, weight: .semibold))
                    .lineSpacing(1.5)
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(13)
        .frame(width: 156, height: 132, alignment: .topLeading)
        .background(
            LinearGradient(colors: [tint.opacity(0.11), .white], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: RoomlyTheme.Shadow.soft.opacity(0.8), radius: 14, x: 0, y: 7)
    }
}

struct GlassMetricCard: View {
    let metric: WeatherMetric

    var body: some View {
        HStack(spacing: 9) {
            SymbolBadge(symbol: metric.symbol, tint: metric.tint, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)

                Text(metric.value)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(metric.caption)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 11)
        .frame(maxWidth: .infinity, minHeight: 58)
        .roomlyCard(cornerRadius: RoomlyTheme.Radius.tile, shadow: RoomlyTheme.Shadow.soft.opacity(0.7))
    }
}

struct ForecastListRow: View {
    let item: DailyForecast

    var body: some View {
        HStack(spacing: 10) {
            Text(item.day)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
                .frame(width: 52, alignment: .leading)

            SymbolBadge(symbol: item.symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 28)

            Text(item.chance)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(item.high)°")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Text("\(item.low)°")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
        }
        .frame(height: 34)
    }
}

struct PricingCard: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.selection()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? RoomlyTheme.ColorToken.primaryBlue : RoomlyTheme.ColorToken.tertiaryInk)
                    .contentTransition(.symbolEffect(.replace))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 7) {
                        Text(plan.title)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(RoomlyTheme.ColorToken.ink)

                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(RoomlyTheme.ColorToken.primaryBlue, in: Capsule())
                        }
                    }

                    Text(plan.subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)

                    Text(plan.period)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: isSelected ? 68 : 58)
            .background(isSelected ? RoomlyTheme.ColorToken.tileSelected : Color(red: 0.945, green: 0.953, blue: 0.965), in: RoundedRectangle(cornerRadius: isSelected ? 20 : 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: isSelected ? 20 : 18, style: .continuous)
                    .stroke(isSelected ? RoomlyTheme.ColorToken.primaryBlue : RoomlyTheme.ColorToken.border, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? RoomlyTheme.Shadow.blue : .clear, radius: 18, x: 0, y: 8)
        }
        .buttonStyle(PressableButtonStyle())
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: isSelected)
    }
}

struct RoomlyWeatherCloud: View {
    var body: some View {
        ZStack {
            Circle().fill(.white).frame(width: 52, height: 34).offset(x: -30, y: 7)
            Circle().fill(.white).frame(width: 54, height: 50).offset(x: 4, y: -6)
            Circle().fill(.white).frame(width: 44, height: 30).offset(x: 34, y: 10)
            RoundedRectangle(cornerRadius: 10).fill(.white).frame(width: 92, height: 20).offset(y: 18)
        }
    }
}

struct SkeletonCard: View {
    var height: CGFloat
    var cornerRadius: CGFloat = RoomlyTheme.Radius.card

    @State private var isBright = false
    @State private var pulse = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        RoomlyTheme.ColorToken.tile,
                        RoomlyTheme.ColorToken.surfaceBlue.opacity(pulse ? 0.95 : 0.55),
                        RoomlyTheme.ColorToken.tile
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .leading) {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.82), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 132)
                .offset(x: isBright ? 360 : -160)
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.42), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .frame(height: height)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: false)) {
                    isBright = true
                }

                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
            .accessibilityHidden(true)
    }
}

struct LoadingStateView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RoomlyTheme.ColorToken.primaryBlue.opacity(0.10))
                    .frame(width: 58, height: 58)

                ProgressView()
                    .tint(RoomlyTheme.ColorToken.primaryBlue)
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .roomlyCard(stroke: RoomlyTheme.ColorToken.border.opacity(0.8), shadow: RoomlyTheme.Shadow.blue.opacity(0.16))
    }
}

struct WeatherFallbackNotice: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            SymbolBadge(symbol: "exclamationmark.triangle.fill", tint: RoomlyTheme.ColorToken.orange, size: 34)

            Text(message)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(RoomlyTheme.ColorToken.orange.opacity(0.25), lineWidth: 1)
        )
    }
}

struct DataStateView: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RoomlyTheme.ColorToken.primaryBlue.opacity(0.08))
                    .frame(width: 76, height: 76)
                    .blur(radius: 3)

                SymbolBadge(symbol: symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 52)
            }

            VStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(RoomlyTheme.ctaGradient, in: Capsule())
                    .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .roomlyCard(stroke: RoomlyTheme.ColorToken.border.opacity(0.8), shadow: RoomlyTheme.Shadow.blue.opacity(0.14))
    }
}

struct AnimatedCardModifier: ViewModifier {
    var delay: Double = 0
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.985)
            .offset(y: isVisible ? 0 : 12)
            .onAppear {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82).delay(delay)) {
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

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview("Components") {
    ZStack {
        RoomlyBackground()
        VStack(spacing: 14) {
            ScreenHeader(title: "Roomly", subtitle: "Minsk, Belarus", trailingSymbol: "crown.fill") {}
            DashboardWeatherCard(
                title: "Indoor Comfort",
                subtitle: "Indoor Estimate",
                value: "22°",
                footnote: "Estimated room comfort looks steady.",
                symbol: "thermometer.medium",
                gradient: RoomlyTheme.blueGradient
            )
            PremiumButton(title: "Continue") {}
        }
        .padding(20)
    }
}
