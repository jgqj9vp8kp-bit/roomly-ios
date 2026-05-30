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

struct CozyInteriorBackdrop: View {
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.94, green: 0.83, blue: 0.68),
                        Color(red: 0.58, green: 0.70, blue: 0.86),
                        accent.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white.opacity(0.25))
                    .frame(width: width * 0.34, height: height * 0.72)
                    .position(x: width * 0.73, y: height * 0.38)
                    .blur(radius: 1.5)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.62), Color(red: 0.84, green: 0.93, blue: 1.0).opacity(0.30)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width * 0.26, height: height * 0.46)
                    .position(x: width * 0.76, y: height * 0.33)

                Capsule()
                    .fill(Color(red: 0.96, green: 0.81, blue: 0.58).opacity(0.82))
                    .frame(width: width * 0.46, height: height * 0.18)
                    .position(x: width * 0.56, y: height * 0.70)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.56, green: 0.44, blue: 0.35).opacity(0.34))
                    .frame(width: width * 0.54, height: height * 0.16)
                    .position(x: width * 0.60, y: height * 0.78)

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.90, blue: 0.76).opacity(0.68))
                    .frame(width: width * 0.17, height: height * 0.12)
                    .position(x: width * 0.43, y: height * 0.66)

                VStack(spacing: 5) {
                    Circle()
                        .fill(Color(red: 0.55, green: 0.74, blue: 0.48).opacity(0.72))
                        .frame(width: width * 0.10, height: width * 0.10)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color(red: 0.35, green: 0.25, blue: 0.19).opacity(0.52))
                        .frame(width: width * 0.025, height: height * 0.15)
                }
                .position(x: width * 0.88, y: height * 0.65)

                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: width * 0.58, height: width * 0.58)
                    .blur(radius: 22)
                    .position(x: width * 0.20, y: height * 0.18)

                LinearGradient(
                    colors: [
                        accent.opacity(0.70),
                        Color.black.opacity(0.22),
                        Color.black.opacity(0.44)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )

                LinearGradient(
                    colors: [.black.opacity(0.42), .black.opacity(0.08), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
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
    var leadingAction: (() -> Void)?
    var showsBackButton = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 12) {
            if showsBackButton {
                IconButton(symbol: "chevron.left") {
                    if let leadingAction {
                        leadingAction()
                    } else {
                        dismiss()
                    }
                }
            } else {
                Color.clear.frame(width: 40, height: 40)
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
        Group {
            if title == "Location Forecast" {
                locationForecastCard
            } else {
                dailyForecastCard
            }
        }
        .frame(maxWidth: .infinity, minHeight: 212, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: shadowColor, radius: 24, x: 0, y: 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(value), \(subtitle). \(footnote)")
    }

    private var locationForecastCard: some View {
        ZStack(alignment: .trailing) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.706, blue: 0.322),
                    Color(red: 1.0, green: 0.553, blue: 0.176),
                    Color(red: 0.949, green: 0.392, blue: 0.094)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.13))
                .frame(width: 166, height: 166)
                .offset(x: -17, y: -15)

            Circle()
                .fill(Color(red: 0.788, green: 0.294, blue: 0.071).opacity(0.16))
                .frame(width: 66, height: 66)
                .offset(x: -35, y: 36)

            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 44, height: 44)
                .offset(x: -92, y: -51)

            HStack(spacing: 12) {
                cardCopy(
                    title: "Location Forecast",
                    subtitle: "Check weather around your current location",
                    buttonTint: Color(red: 0.941, green: 0.420, blue: 0.098)
                )
                .frame(maxWidth: 180, alignment: .leading)

                Spacer(minLength: 0)

                LocationForecastIllustration()
                .frame(width: 122, height: 122)
            }
            .padding(.leading, 24)
            .padding(.trailing, 15)
        }
    }

    private var dailyForecastCard: some View {
        ZStack(alignment: .trailing) {
            LinearGradient(
                colors: [
                    Color(red: 0.537, green: 0.349, blue: 1.0),
                    Color(red: 0.416, green: 0.302, blue: 0.973),
                    Color(red: 0.431, green: 0.271, blue: 0.910)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            DailyForecastIllustration(
                temperature: value,
                condition: subtitle,
                footnote: footnote
            )
            .allowsHitTesting(false)

            HStack {
                cardCopy(
                    title: "Daily Forecast",
                    subtitle: "Every day, you can check\nthe forecast.",
                    buttonTint: .black
                )
                .frame(width: 174, alignment: .leading)

                Spacer(minLength: 0)
            }
            .padding(.leading, 24)
            .padding(.trailing, 15)
        }
    }

    private func cardCopy(title: String, subtitle: String, buttonTint: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .lineSpacing(0)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .lineSpacing(2)
                .foregroundStyle(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)

            Text("Explore")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(buttonTint)
                .frame(width: 98, height: 34)
                .background(.white, in: Capsule())
        }
    }

    private var shadowColor: Color {
        title == "Location Forecast" ? Color(red: 0.949, green: 0.424, blue: 0.094).opacity(0.16) : .black.opacity(0.12)
    }
}

private struct LocationForecastIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.20))
                .frame(width: 28, height: 28)
                .position(x: 18, y: 40)

            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 58, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, Color(red: 0.969, green: 0.831, blue: 0.361))
                .position(x: 70, y: 48)

            Image(systemName: "map.fill")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(.white.opacity(0.95))
                .position(x: 55, y: 92)

            Circle()
                .fill(Color(red: 0.184, green: 0.525, blue: 1.0))
                .frame(width: 36, height: 36)
                .position(x: 94, y: 92)

            Image(systemName: "mappin")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(.white)
                .position(x: 94, y: 91)
        }
    }
}

private struct DailyForecastIllustration: View {
    let temperature: String
    let condition: String
    let footnote: String

    var body: some View {
        GeometryReader { proxy in
            let baseWidth: CGFloat = 362
            let baseHeight: CGFloat = 212
            let scale = min(proxy.size.width / baseWidth, proxy.size.height / baseHeight)
            let originX = max(0, proxy.size.width - baseWidth * scale)

            ZStack {
                Circle()
                    .fill(.white.opacity(0.07))
                    .frame(width: 144, height: 144)
                    .position(x: 266, y: 126)

                Path { path in
                    path.move(to: CGPoint(x: 14, y: 158))
                    path.addCurve(to: CGPoint(x: 76, y: 160), control1: CGPoint(x: 33, y: 142), control2: CGPoint(x: 54, y: 176))
                }
                .stroke(.white.opacity(0.10), style: StrokeStyle(lineWidth: 2, lineCap: .round))

                RoomlyWeatherCloud()
                    .scaleEffect(0.84)
                    .frame(width: 77, height: 58)
                    .position(x: 227.5, y: 88)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(red: 1.0, green: 0.886, blue: 0.278))
                    .rotationEffect(.degrees(4))
                    .position(x: 218, y: 121)

                rainDrop
                    .position(x: 189, y: 121)
                rainDrop
                    .position(x: 231, y: 138)
                rainDrop
                    .position(x: 207, y: 155)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Today weather")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.86)

                    Text(condition)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(1)
                        .minimumScaleFactor(0.86)

                    Text(temperature)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .frame(width: 84, alignment: .leading)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                .position(x: 308, y: 62)

                forecastPill("Friday 8 °C Cloud", width: 96)
                    .position(x: 290, y: 142.5)
                forecastPill("Sunday 13 °C", width: 77)
                    .position(x: 288.5, y: 164.5)
                forecastPill("Shower", width: 58)
                    .position(x: 305, y: 186.5)
            }
            .frame(width: baseWidth, height: baseHeight)
            .scaleEffect(scale, anchor: .topLeading)
            .position(x: originX + (baseWidth * scale / 2), y: baseHeight * scale / 2)
        }
    }

    private func forecastPill(_ text: String, width: CGFloat) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(RoomlyTheme.ColorToken.sun)
                .frame(width: 8, height: 8)

            Text(text)
                .font(.system(size: 5, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 5)
        .frame(width: width, height: 17, alignment: .leading)
        .background(.white.opacity(0.15), in: Capsule())
    }

    private var rainDrop: some View {
        Capsule()
            .fill(Color(red: 0.918, green: 0.957, blue: 1.0))
            .frame(width: 7, height: 22)
            .rotationEffect(.degrees(28))
    }
}

struct ComfortGaugeDashboardCard: View {
    let dashboard: WeatherDashboard
    let unit: TemperatureUnit

    var body: some View {
        cardContents
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Room temperature")
            .accessibilityValue("Indoor estimate \(dashboard.snapshot.indoorEstimate), comfort index \(dashboard.comfort.index), \(dashboard.comfort.level.rawValue)")
            .accessibilityHint("Opens room settings")
    }

    private var cardContents: some View {
        ZStack(alignment: .trailing) {
            Image("IndoorRoomPhoto")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 212)
                .clipped()

            LinearGradient(
                colors: [
                    Color(red: 0.047, green: 0.431, blue: 0.957).opacity(0.44),
                    Color(red: 0.031, green: 0.361, blue: 0.847).opacity(0.60),
                    Color(red: 0.016, green: 0.149, blue: 0.373).opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 172, height: 172)
                .offset(x: -18, y: -8)

            Circle()
                .fill(RoomlyTheme.ColorToken.primaryBlue.opacity(0.13))
                .frame(width: 104, height: 104)
                .offset(x: -24, y: 44)

            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 46, height: 46)
                .offset(x: -118, y: -58)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Room Temp")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Create comfortable indoor conditions")
                        .font(.system(size: 13, weight: .medium))
                        .lineSpacing(3)
                        .foregroundStyle(Color(red: 0.918, green: 0.957, blue: 1.0))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Explore")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                        .frame(width: 98, height: 34)
                        .background(.white, in: Capsule())

                    if dashboard.usesCustomRoomSettings {
                        Text("Using your room settings")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white.opacity(0.86))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.14), in: Capsule())
                    }
                }
                .frame(maxWidth: 174, alignment: .leading)

                Spacer(minLength: 0)

                RoomTempThermometerIllustration()
                    .frame(width: 108, height: 140)
            }
            .padding(.leading, 22)
            .padding(.trailing, 27)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
                .padding(1)
        }
        .frame(maxWidth: .infinity, minHeight: 212)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: RoomlyTheme.ColorToken.primaryBlue.opacity(0.16), radius: 24, x: 0, y: 14)
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: dashboard.snapshot.indoorEstimate)
    }
}

struct RoomTempThermometerIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 54, height: 54)
                .shadow(color: Color(red: 0.008, green: 0.294, blue: 0.667).opacity(0.20), radius: 18, x: 0, y: 8)
                .position(x: 57, y: 109)

            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(.white)
                .frame(width: 26, height: 92)
                .position(x: 57, y: 53)

            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color(red: 0.137, green: 0.525, blue: 1.0))
                .frame(width: 10, height: 71)
                .position(x: 57, y: 58)

            Circle()
                .fill(Color(red: 0.137, green: 0.525, blue: 1.0))
                .frame(width: 32, height: 32)
                .position(x: 57, y: 110)

            Circle()
                .fill(Color(red: 0.957, green: 0.643, blue: 0.227))
                .frame(width: 26, height: 26)
                .position(x: 15, y: 47)

            Circle()
                .fill(Color(red: 0.424, green: 0.827, blue: 1.0))
                .frame(width: 21, height: 21)
                .position(x: 88, y: 25)

            Image(systemName: "plus")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .position(x: 15, y: 47)

            Image(systemName: "minus")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(.white)
                .position(x: 88, y: 25)
        }
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(metric.title)
        .accessibilityValue("\(metric.value), \(metric.caption)")
    }
}

struct ForecastListRow: View {
    let item: DailyForecast
    let minTemperature: Int
    let maxTemperature: Int

    var body: some View {
        HStack(spacing: 9) {
            Text(item.day)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.114, green: 0.149, blue: 0.20))
                .frame(width: 52, alignment: .leading)

            WeeklyForecastIcon(symbol: item.symbol)

            Text(item.chance)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(red: 0.604, green: 0.651, blue: 0.710))
                .frame(width: 34, alignment: .leading)

            WeeklyTemperatureRange(
                low: item.low,
                high: item.high,
                minTemperature: minTemperature,
                maxTemperature: maxTemperature
            )
            .frame(width: 86, height: 14)

            Text("\(item.high)°")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.067, green: 0.094, blue: 0.153))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(item.low)°")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.604, green: 0.651, blue: 0.710))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 40)
    }
}

private struct WeeklyForecastIcon: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 15, weight: .bold))
            .symbolRenderingMode(.palette)
            .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue, RoomlyTheme.ColorToken.sun, RoomlyTheme.ColorToken.sky)
            .frame(width: 26, height: 26)
            .background(Color(red: 0.957, green: 0.973, blue: 0.992), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

private struct WeeklyTemperatureRange: View {
    let low: Int
    let high: Int
    let minTemperature: Int
    let maxTemperature: Int

    private var span: Double {
        max(1, Double(maxTemperature - minTemperature))
    }

    private var lowPosition: CGFloat {
        normalized(low)
    }

    private var highPosition: CGFloat {
        normalized(high)
    }

    private var rangeWidth: CGFloat {
        max(8, highPosition - lowPosition)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(red: 0.933, green: 0.953, blue: 0.973))
                .frame(width: 86, height: 3)
                .offset(y: 0.5)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.612, green: 0.812, blue: 1.0),
                            Color(red: 0.373, green: 0.659, blue: 1.0),
                            Color(red: 0.949, green: 0.780, blue: 0.416)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: rangeWidth, height: 5)
                .offset(x: lowPosition, y: 0.5)

            temperatureDot(color: Color(red: 0.443, green: 0.725, blue: 1.0))
                .offset(x: lowPosition - 5)

            temperatureDot(color: Color(red: 0.992, green: 0.729, blue: 0.231))
                .offset(x: highPosition - 5)
        }
        .frame(width: 86, height: 14)
    }

    private func normalized(_ temperature: Int) -> CGFloat {
        let value = (Double(temperature - minTemperature) / span) * 76 + 5
        return CGFloat(min(76, max(5, value)))
    }

    private func temperatureDot(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
    }
}

struct PricingCard: View {
    let offer: SubscriptionOffer
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
                        Text(offer.title)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(RoomlyTheme.ColorToken.ink)

                        if let badge = offer.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(RoomlyTheme.ColorToken.primaryBlue, in: Capsule())
                        }
                    }

                    Text(offer.subtitle.isEmpty ? offer.periodTitle.capitalized : offer.subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(offer.displayPrice)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)

                    Text(offer.periodTitle)
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
            ScreenHeader(title: "Roomly", subtitle: "Your Location", trailingSymbol: "crown.fill") {}
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
