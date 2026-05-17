import SwiftUI

enum RoomlyTheme {
    enum ColorToken {
        static let ink = Color(red: 0.02, green: 0.03, blue: 0.07)
        static let midnight = Color(red: 0.04, green: 0.07, blue: 0.14)
        static let deepPlum = Color(red: 0.10, green: 0.06, blue: 0.13)
        static let cyan = Color(red: 0.20, green: 0.82, blue: 0.92)
        static let blue = Color(red: 0.30, green: 0.48, blue: 0.96)
        static let mint = Color(red: 0.40, green: 0.94, blue: 0.76)
        static let gold = Color(red: 0.92, green: 0.66, blue: 0.28)
    }

    enum Spacing {
        static let page: CGFloat = 20
        static let card: CGFloat = 20
        static let section: CGFloat = 24
        static let item: CGFloat = 14
    }

    enum Radius {
        static let card: CGFloat = 28
        static let hero: CGFloat = 34
        static let control: CGFloat = 18
        static let capsule: CGFloat = 999
    }

    enum Shadow {
        static let cardColor = Color.black.opacity(0.30)
        static let glowColor = ColorToken.cyan.opacity(0.28)
    }

    static let background = LinearGradient(
        colors: [
            ColorToken.ink,
            ColorToken.midnight,
            ColorToken.deepPlum
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let aurora = LinearGradient(
        colors: [
            ColorToken.cyan.opacity(0.38),
            ColorToken.blue.opacity(0.22),
            ColorToken.mint.opacity(0.20)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let premium = LinearGradient(
        colors: [
            ColorToken.cyan,
            ColorToken.blue,
            ColorToken.gold
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassSurface = LinearGradient(
        colors: [
            Color.white.opacity(0.18),
            Color.white.opacity(0.08),
            Color.white.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct RoomlyBackground: View {
    var body: some View {
        ZStack {
            RoomlyTheme.background

            LinearGradient(
                colors: [
                    RoomlyTheme.ColorToken.cyan.opacity(0.22),
                    Color.clear,
                    Color.indigo.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    Color.clear,
                    RoomlyTheme.ColorToken.gold.opacity(0.10),
                    Color.clear
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
        .ignoresSafeArea()
    }
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 28
    var borderOpacity: Double = 0.18
    var glow: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.76))
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(RoomlyTheme.glassSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(borderOpacity + 0.16),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: glow ? RoomlyTheme.Shadow.glowColor : .clear, radius: glow ? 24 : 0, x: 0, y: 10)
            .shadow(color: RoomlyTheme.Shadow.cardColor, radius: 28, x: 0, y: 18)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 28, borderOpacity: Double = 0.18, glow: Bool = false) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, borderOpacity: borderOpacity, glow: glow))
    }
}
