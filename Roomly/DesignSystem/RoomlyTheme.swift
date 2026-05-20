import SwiftUI

enum RoomlyTheme {
    enum ColorToken {
        static let background = Color(red: 0.972, green: 0.984, blue: 1.0)
        static let surface = Color.white
        static let surfaceBlue = Color(red: 0.945, green: 0.976, blue: 1.0)
        static let tile = Color(red: 0.965, green: 0.98, blue: 0.996)
        static let tileSelected = Color(red: 0.918, green: 0.957, blue: 1.0)
        static let border = Color(red: 0.894, green: 0.933, blue: 0.976)
        static let ink = Color(red: 0.067, green: 0.078, blue: 0.098)
        static let inkBlue = Color(red: 0.09, green: 0.196, blue: 0.302)
        static let secondaryInk = Color(red: 0.42, green: 0.47, blue: 0.55)
        static let tertiaryInk = Color(red: 0.61, green: 0.65, blue: 0.71)
        static let primaryBlue = Color(red: 0.09, green: 0.404, blue: 0.949)
        static let sky = Color(red: 0.353, green: 0.702, blue: 1.0)
        static let deepBlue = Color(red: 0.114, green: 0.306, blue: 0.847)
        static let paleBlue = Color(red: 0.918, green: 0.957, blue: 1.0)
        static let orange = Color(red: 1.0, green: 0.553, blue: 0.176)
        static let sun = Color(red: 0.992, green: 0.729, blue: 0.231)
        static let green = Color(red: 0.125, green: 0.788, blue: 0.592)
        static let purple = Color(red: 0.431, green: 0.271, blue: 0.91)
        static let red = Color(red: 1.0, green: 0.373, blue: 0.427)
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 20
        static let screenTop: CGFloat = 12
        static let section: CGFloat = 14
        static let card: CGFloat = 12
        static let row: CGFloat = 10
    }

    enum Radius {
        static let screen: CGFloat = 34
        static let hero: CGFloat = 28
        static let card: CGFloat = 22
        static let tile: CGFloat = 18
        static let button: CGFloat = 29
        static let small: CGFloat = 12
    }

    enum Shadow {
        static let soft = Color(red: 0.384, green: 0.517, blue: 0.682).opacity(0.18)
        static let blue = ColorToken.primaryBlue.opacity(0.26)
        static let warm = ColorToken.orange.opacity(0.20)
    }

    static let blueGradient = LinearGradient(
        colors: [ColorToken.sky, Color(red: 0.184, green: 0.502, blue: 0.929), ColorToken.deepBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let orangeGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.706, blue: 0.322), ColorToken.orange, Color(red: 0.949, green: 0.392, blue: 0.094)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let purpleGradient = LinearGradient(
        colors: [Color(red: 0.537, green: 0.349, blue: 1.0), ColorToken.purple, Color(red: 0.431, green: 0.271, blue: 0.91)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ctaGradient = LinearGradient(
        colors: [Color(red: 0.18, green: 0.545, blue: 1.0), ColorToken.primaryBlue],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let insightGradient = LinearGradient(
        colors: [ColorToken.paleBlue, Color.white],
        startPoint: .leading,
        endPoint: .trailing
    )
}

struct RoomlyBackground: View {
    var body: some View {
        RoomlyTheme.ColorToken.background
            .ignoresSafeArea()
    }
}

struct CardSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = RoomlyTheme.Radius.card
    var stroke: Color = RoomlyTheme.ColorToken.border
    var shadow: Color = RoomlyTheme.Shadow.soft

    func body(content: Content) -> some View {
        content
            .background(RoomlyTheme.ColorToken.surface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            )
            .shadow(color: shadow, radius: 18, x: 0, y: 8)
    }
}

extension View {
    func roomlyCard(
        cornerRadius: CGFloat = RoomlyTheme.Radius.card,
        stroke: Color = RoomlyTheme.ColorToken.border,
        shadow: Color = RoomlyTheme.Shadow.soft
    ) -> some View {
        modifier(CardSurfaceModifier(cornerRadius: cornerRadius, stroke: stroke, shadow: shadow))
    }

    func glassCard(
        cornerRadius: CGFloat = RoomlyTheme.Radius.card,
        borderOpacity: Double = 1,
        glow: Bool = false
    ) -> some View {
        roomlyCard(
            cornerRadius: cornerRadius,
            stroke: RoomlyTheme.ColorToken.border.opacity(borderOpacity),
            shadow: glow ? RoomlyTheme.Shadow.blue : RoomlyTheme.Shadow.soft
        )
    }
}
