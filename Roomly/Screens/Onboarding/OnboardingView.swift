import SwiftUI

struct OnboardingView: View {
    @ObservedObject var locationViewModel: LocationViewModel
    let onComplete: () -> Void

    @State private var selectedPage = 0
    @State private var isShowingLocationStep = false
    @State private var showsManualLocation = false
    private let pages = MockOnboardingData.pages
    private let totalFlowSteps = 3

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if isShowingLocationStep {
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
                            pageCount: totalFlowSteps,
                            locationLabel: locationViewModel.onboardingLocationDisplayName
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
        .fullScreenCover(isPresented: $showsManualLocation) {
            ManualLocationView(locationViewModel: locationViewModel, onSelectionComplete: onComplete)
        }
    }

    private func advance(from index: Int) {
        HapticFeedback.selection()
        if index == pages.count - 1 {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                isShowingLocationStep = true
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
    let locationLabel: String
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let metrics = OnboardingLayoutMetrics(
                size: proxy.size,
                safeAreaInsets: proxy.safeAreaInsets,
                minimumContentHeight: page.minimumContentHeight,
                preferredHeroHeight: page.preferredHeroHeight
            )

            VStack(spacing: 0) {
                hero
                    .frame(height: metrics.heroHeight)

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
                .padding(.bottom, metrics.contentBottomPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
    }

    @ViewBuilder
    private var hero: some View {
        switch page.kind {
        case .location:
            LocationMapHero(locationLabel: locationLabel)
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

private extension OnboardingPage {
    var minimumContentHeight: CGFloat {
        switch kind {
        case .location:
            292
        case .comfort:
            292
        }
    }

    var preferredHeroHeight: CGFloat {
        switch kind {
        case .location:
            560
        case .comfort:
            560
        }
    }
}

private struct OnboardingLocationStep: View {
    @ObservedObject var locationViewModel: LocationViewModel
    let onManualLocation: () -> Void
    let onComplete: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let metrics = OnboardingLayoutMetrics(
                size: proxy.size,
                safeAreaInsets: proxy.safeAreaInsets,
                minimumContentHeight: 390,
                preferredHeroHeight: 560
            )

            VStack(spacing: 0) {
                LocationMapHero(locationLabel: locationViewModel.onboardingLocationDisplayName)
                    .frame(height: metrics.heroHeight)

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
                .padding(.bottom, metrics.contentBottomPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
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

private struct OnboardingLayoutMetrics {
    let size: CGSize
    let safeAreaInsets: EdgeInsets
    let minimumContentHeight: CGFloat
    let preferredHeroHeight: CGFloat

    var heroHeight: CGFloat {
        let availableHeight = size.height + safeAreaInsets.top
        let desiredHeroHeight = min(preferredHeroHeight, availableHeight * 0.66)
        let maximumHeroHeight = size.height - minimumContentHeight
        return max(240, min(desiredHeroHeight, maximumHeroHeight))
    }

    var contentBottomPadding: CGFloat {
        max(24, safeAreaInsets.bottom + 20)
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
        .padding(12)
        .roomlyCard(cornerRadius: 18)
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
    let locationLabel: String

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

                Text(locationLabel)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .lineLimit(1)
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
        GeometryReader { proxy in
            let designWidth: CGFloat = 393
            let designHeight: CGFloat = 560
            let scale = proxy.size.width / designWidth

            ZStack(alignment: .topLeading) {
                Image("IndoorRoomPhoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: designWidth, height: designHeight)
                    .clipped()

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                RoomlyTheme.ColorToken.primaryBlue.opacity(0.34),
                                Color(red: 0.067, green: 0.42, blue: 0.91).opacity(0.47),
                                Color(red: 0.031, green: 0.141, blue: 0.357).opacity(0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: designWidth, height: designHeight)

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .blur(radius: 16)
                    .frame(width: 210, height: 210)
                    .position(x: 105, y: 105)

                Circle()
                    .fill(Color(red: 0.875, green: 0.957, blue: 1.0).opacity(0.13))
                    .blur(radius: 18)
                    .frame(width: 190, height: 190)
                    .position(x: 283, y: 107)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Smart Room Comfort")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(RoomlyTheme.ColorToken.ink)

                            Text("Estimated from room and weather signals")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                        }

                        Spacer()

                        VStack(spacing: 0) {
                            Text("86")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundStyle(.white)

                            Text("score")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Color(red: 0.867, green: 0.922, blue: 1.0))
                        }
                        .frame(width: 58, height: 58)
                        .background(RoomlyTheme.ctaGradient, in: Circle())
                    }

                    HStack(spacing: 9) {
                        MiniComfortSignal(symbol: "face.smiling", symbolColor: RoomlyTheme.ColorToken.green, value: "Good")
                        MiniComfortSignal(symbol: "thermometer.medium", symbolColor: RoomlyTheme.ColorToken.primaryBlue, value: "74°F")
                        MiniComfortSignal(symbol: "wind", symbolColor: RoomlyTheme.ColorToken.sky, value: "Calm")
                    }

                    Text("Comfort looks stable for the next few hours.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                }
                .padding(18)
                .frame(width: 329, height: 190)
                .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.72), lineWidth: 1))
                .shadow(color: Color(red: 0.012, green: 0.118, blue: 0.275).opacity(0.31), radius: 36, x: 0, y: 18)
                .position(x: 196.5, y: 199)

                Label("Weather-aware room estimates", systemImage: "cloud.sun.fill")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(width: 245, height: 44)
                    .background(Color.white.opacity(0.23), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.40), lineWidth: 1))
                    .position(x: 196.5, y: 320)
            }
            .frame(width: designWidth, height: designHeight)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .clipped()
        }
    }
}

private struct MiniComfortSignal: View {
    let symbol: String
    let symbolColor: Color
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(symbolColor)

            Text(value)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(RoomlyTheme.ColorToken.tile, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color(red: 0.875, green: 0.918, blue: 0.973), lineWidth: 1))
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
