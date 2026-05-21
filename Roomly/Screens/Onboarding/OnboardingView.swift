import SwiftUI

struct OnboardingView: View {
    @ObservedObject var locationViewModel: LocationViewModel
    let onComplete: () -> Void

    @State private var selectedPage = 0
    @State private var showsLocationStep = false
    @State private var showsManualLocation = false
    private let pages = MockOnboardingData.pages

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if showsLocationStep {
                OnboardingLocationStep(
                    locationViewModel: locationViewModel,
                    onManualLocation: {
                        showsManualLocation = true
                    },
                    onComplete: onComplete
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(
                            page: page,
                            selectedPage: selectedPage,
                            pageCount: pages.count
                        ) {
                            advance(from: index)
                        }
                        .tag(index)
                        .transition(.opacity.combined(with: .scale(scale: 0.985)))
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .top)
                .animation(.spring(response: 0.45, dampingFraction: 0.86), value: selectedPage)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: showsLocationStep)
        .fullScreenCover(isPresented: $showsManualLocation) {
            ManualLocationView(locationViewModel: locationViewModel) {
                onComplete()
            }
        }
    }

    private func advance(from index: Int) {
        HapticFeedback.selection()
        if index == pages.count - 1 {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                showsLocationStep = true
            }
        } else {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                selectedPage = index + 1
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let selectedPage: Int
    let pageCount: Int
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            hero
                .frame(height: 560)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(page.title)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(page.subtitle)
                        .font(.system(size: 17, weight: .medium))
                        .lineSpacing(2)
                        .foregroundStyle(Color(red: 0.122, green: 0.161, blue: 0.216))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 12)

                VStack(spacing: 14) {
                    pageDots

                    PremiumButton(title: "Continue", symbol: nil, action: onContinue)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }

    @ViewBuilder
    private var hero: some View {
        switch page.kind {
        case .location:
            LocationMapHero()
        case .comfort:
            IndoorComfortHero()
        }
    }

    private var pageDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == selectedPage ? RoomlyTheme.ColorToken.primaryBlue : Color(red: 0.82, green: 0.88, blue: 0.95))
                    .frame(width: index == selectedPage ? 22 : 8, height: 8)
            }
        }
    }
}

private struct OnboardingLocationStep: View {
    @ObservedObject var locationViewModel: LocationViewModel
    let onManualLocation: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LocationMapHero()
                .frame(height: 560)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Choose Your Location")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Allow GPS or enter a city manually to personalize your forecast and comfort insights.")
                        .font(.system(size: 17, weight: .medium))
                        .lineSpacing(2)
                        .foregroundStyle(Color(red: 0.122, green: 0.161, blue: 0.216))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 12)

                VStack(spacing: 14) {
                    LocationPermissionStatusPanel(
                        viewModel: locationViewModel,
                        onManualLocation: {
                            HapticFeedback.selection()
                            onManualLocation()
                        }
                    )

                    PremiumButton(title: primaryButtonTitle, symbol: nil) {
                        handlePrimaryAction()
                    }
                    .disabled(locationViewModel.isLoading)
                    .opacity(locationViewModel.isLoading ? 0.72 : 1)

                    Button {
                        HapticFeedback.selection()
                        onComplete()
                    } label: {
                        Text("Continue for Now")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                            .frame(height: 28)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }

    private var primaryButtonTitle: String {
        if locationViewModel.isLoading {
            return "Requesting..."
        }

        if locationViewModel.hasUsableLocation {
            return "Continue"
        }

        return "Allow Location"
    }

    private func handlePrimaryAction() {
        if locationViewModel.hasUsableLocation {
            HapticFeedback.success()
            onComplete()
            return
        }

        Task {
            let isAllowed = await locationViewModel.requestPermissionAndFetchLocation()
            if isAllowed {
                HapticFeedback.success()
                onComplete()
            }
        }
    }
}

private struct LocationPermissionStatusPanel: View {
    @ObservedObject var viewModel: LocationViewModel
    let onManualLocation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                SymbolBadge(symbol: statusSymbol, tint: statusTint, size: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusTitle)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(RoomlyTheme.ColorToken.ink)

                    Text(statusMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(RoomlyTheme.ColorToken.primaryBlue)
                }
            }

            if shouldShowManualButton {
                Button {
                    HapticFeedback.selection()
                    onManualLocation()
                } label: {
                    Label("Enter Location Manually", systemImage: "keyboard")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(RoomlyTheme.ColorToken.surfaceBlue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(12)
        .roomlyCard(cornerRadius: 18)
    }

    private var shouldShowManualButton: Bool {
        true
    }

    private var statusSymbol: String {
        if viewModel.locationSource == .manual {
            return "mappin.circle.fill"
        }

        if viewModel.permissionStatus.isAuthorized {
            return "location.fill"
        }

        switch viewModel.permissionStatus {
        case .notDetermined:
            return "location.circle.fill"
        case .denied, .restricted:
            return "location.slash.fill"
        case .authorizedWhenInUse:
            return "location.fill"
        }
    }

    private var statusTint: Color {
        if viewModel.locationSource == .manual {
            return RoomlyTheme.ColorToken.primaryBlue
        }

        if viewModel.permissionStatus.isAuthorized {
            return RoomlyTheme.ColorToken.green
        }

        switch viewModel.permissionStatus {
        case .notDetermined:
            return RoomlyTheme.ColorToken.primaryBlue
        case .denied, .restricted:
            return RoomlyTheme.ColorToken.orange
        case .authorizedWhenInUse:
            return RoomlyTheme.ColorToken.green
        }
    }

    private var statusTitle: String {
        if viewModel.locationSource == .manual {
            return viewModel.activeLocationDisplayName
        }

        switch viewModel.permissionStatus {
        case .notDetermined:
            return "Enable location forecast"
        case .authorizedWhenInUse:
            return viewModel.displayName
        case .denied:
            return "Location not enabled"
        case .restricted:
            return "Location restricted"
        }
    }

    private var statusMessage: String {
        if viewModel.locationSource == .manual {
            return "Manual city selected. Roomly will personalize Weather Insights from saved coordinates."
        }

        if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
            return errorMessage
        }

        switch viewModel.permissionStatus {
        case .notDetermined:
            return "Roomly can use your coordinates for location-aware Weather Insights."
        case .authorizedWhenInUse:
            return viewModel.currentCoordinates?.formatted ?? "Location permission is enabled."
        case .denied:
            return "You can continue without GPS or choose a city manually."
        case .restricted:
            return "You can continue by choosing a city manually."
        }
    }
}

private struct LocationMapHero: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color(red: 0.933, green: 0.965, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )

            MapLines()
                .stroke(Color(red: 0.82, green: 0.91, blue: 0.97), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                .frame(width: 390, height: 460)
                .offset(y: 20)

            ForEach(0..<9, id: \.self) { index in
                RoundedRectangle(cornerRadius: CGFloat([22, 25, 19, 27, 29, 22, 29, 32, 24][index]), style: .continuous)
                    .fill(Color(red: 0.91, green: 0.95, blue: 0.98))
                    .frame(width: CGFloat([118, 122, 92, 152, 132, 116, 126, 144, 88][index]), height: CGFloat([44, 50, 38, 54, 58, 44, 58, 64, 38][index]))
                    .position(CGPoint(x: [82, 307, 90, 258, 81, 300, 111, 292, 54][index], y: [58, 47, 135, 123, 267, 262, 433, 426, 484][index]))
            }

            Circle()
                .fill(RadialGradient(colors: [RoomlyTheme.ColorToken.sky.opacity(0.24), .clear], center: .center, startRadius: 8, endRadius: 92))
                .frame(width: 180, height: 180)
                .offset(y: 92)

            VStack(spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 92, weight: .bold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(RoomlyTheme.ColorToken.primaryBlue, .white)

                Text("Minsk")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white, in: Capsule())
                    .shadow(color: RoomlyTheme.Shadow.soft, radius: 12, x: 0, y: 8)
            }
            .offset(y: 75)
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 0))
    }
}

private struct IndoorComfortHero: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.051, green: 0.243, blue: 0.58), RoomlyTheme.ColorToken.primaryBlue, Color(red: 0.73, green: 0.91, blue: 1.0)],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.20), RoomlyTheme.ColorToken.primaryBlue.opacity(0.18), Color.black.opacity(0.38)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Circle()
                .fill(Color.white.opacity(0.15))
                .blur(radius: 16)
                .frame(width: 210, height: 210)
                .offset(x: -125, y: -150)

            Circle()
                .fill(RoomlyTheme.ColorToken.sun)
                .frame(width: 58, height: 58)
                .shadow(color: RoomlyTheme.ColorToken.sun.opacity(0.45), radius: 18, x: 0, y: 8)
                .offset(x: 120, y: -200)

            WeatherCloud()
                .frame(width: 128, height: 58)
                .offset(x: -118, y: -175)
                .opacity(0.75)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Comfort Index")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                        Text("82")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundStyle(RoomlyTheme.ColorToken.ink)
                    }

                    Spacer()

                    SymbolBadge(symbol: "house.fill", tint: RoomlyTheme.ColorToken.primaryBlue, size: 46)
                }

                HStack(spacing: 9) {
                    MiniComfortMetric(title: "Indoor", value: "15°")
                    MiniComfortMetric(title: "Humidity", value: "68%")
                    MiniComfortMetric(title: "Wind", value: "11")
                }

                Text("Estimated comfort looks stable for the next few hours.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
            }
            .padding(18)
            .frame(width: 329, height: 190)
            .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.72), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.24), radius: 28, x: 0, y: 18)
            .offset(y: -80)

            Label("Weather-aware room estimates", systemImage: "cloud.sun.fill")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(width: 245, height: 44)
                .background(Color.white.opacity(0.23), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.40), lineWidth: 1))
                .offset(y: 19)
        }
        .clipped()
    }
}

private struct MiniComfortMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct WeatherCloud: View {
    var body: some View {
        ZStack {
            Circle().fill(.white).frame(width: 52, height: 34).offset(x: -30, y: 7)
            Circle().fill(.white).frame(width: 54, height: 50).offset(x: 4, y: -6)
            Circle().fill(.white).frame(width: 44, height: 30).offset(x: 34, y: 10)
            RoundedRectangle(cornerRadius: 10).fill(.white).frame(width: 92, height: 20).offset(y: 18)
        }
    }
}

private struct MapLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY + 122))
        path.addCurve(to: CGPoint(x: rect.maxX - 20, y: rect.minY + 84), control1: CGPoint(x: rect.minX + 130, y: rect.minY + 24), control2: CGPoint(x: rect.maxX - 150, y: rect.minY + 170))
        path.move(to: CGPoint(x: rect.minX + 80, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.minX + 260, y: rect.maxY), control1: CGPoint(x: rect.minX + 50, y: rect.minY + 170), control2: CGPoint(x: rect.minX + 300, y: rect.minY + 255))
        path.move(to: CGPoint(x: rect.minX + 10, y: rect.minY + 286))
        path.addCurve(to: CGPoint(x: rect.maxX - 10, y: rect.minY + 336), control1: CGPoint(x: rect.minX + 130, y: rect.minY + 240), control2: CGPoint(x: rect.maxX - 150, y: rect.minY + 410))
        return path
    }
}

#Preview {
    OnboardingView(locationViewModel: LocationViewModel(), onComplete: {})
}
