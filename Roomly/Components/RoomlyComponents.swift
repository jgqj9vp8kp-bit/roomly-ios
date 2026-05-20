import SwiftUI

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
        Button(action: action) {
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
        Button(action: action) {
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
            .shadow(color: RoomlyTheme.Shadow.blue, radius: 24, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryPillButton: View {
    let title: String
    var symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.94), in: Capsule())
        }
        .buttonStyle(.plain)
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
        Button(action: action) {
            HStack(spacing: 12) {
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
        .buttonStyle(.plain)
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

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(RoomlyTheme.ColorToken.tile)
            .overlay(alignment: .leading) {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.72), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 120)
                .offset(x: isBright ? 360 : -160)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .frame(height: height)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: false)) {
                    isBright = true
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
            ProgressView()
                .tint(RoomlyTheme.ColorToken.primaryBlue)

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
        .roomlyCard()
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
            SymbolBadge(symbol: symbol, tint: RoomlyTheme.ColorToken.primaryBlue, size: 50)

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
        .roomlyCard()
    }
}

struct AnimatedCardModifier: ViewModifier {
    var delay: Double = 0
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.28).delay(delay)) {
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
                footnote: "Comfort looks stable for the next few hours.",
                symbol: "thermometer.medium",
                gradient: RoomlyTheme.blueGradient
            )
            PremiumButton(title: "Continue") {}
        }
        .padding(20)
    }
}
