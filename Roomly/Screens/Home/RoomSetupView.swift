import SwiftUI

struct RoomSetupView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @State private var controls: [RoomControl] = []
    @State private var insulation = "Medium"

    var body: some View {
        ZStack {
            RoomlyBackground()

            VStack(spacing: 0) {
                DetailNavigationBar(title: "Set Room Info")
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                content
            }
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await weatherViewModel.loadIfNeeded()
            syncControls()
        }
        .onChange(of: weatherViewModel.dashboard?.roomControls.count ?? 0) { _, _ in
            syncControls()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch weatherViewModel.phase {
        case .idle, .loading:
            VStack(spacing: 14) {
                SkeletonCard(height: 232, cornerRadius: 18)
                SkeletonCard(height: 180, cornerRadius: 26)
                LoadingStateView(title: "Loading Room Setup", subtitle: "Preparing room controls.")
                    .padding(.horizontal, 20)
                Spacer()
            }
        case .loaded:
            if controls.isEmpty {
                DataStateView(symbol: "slider.horizontal.3", title: "No room controls", message: "Room controls are not available yet.", actionTitle: "Reload") {
                    Task { await weatherViewModel.reload() }
                }
                .padding(.horizontal, 20)
            } else {
                setupContent
            }
        case .empty(let message):
            DataStateView(symbol: "slider.horizontal.3", title: "No room controls", message: message, actionTitle: "Reload") {
                Task { await weatherViewModel.reload() }
            }
            .padding(.horizontal, 20)
        case .failed(let message):
            DataStateView(symbol: "exclamationmark.triangle.fill", title: "Room setup unavailable", message: message, actionTitle: "Try Again") {
                Task { await weatherViewModel.reload() }
            }
            .padding(.horizontal, 20)
        }
    }

    private var setupContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                ForEach($controls) { $control in
                    RoomControlRow(control: $control)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(RoomlyTheme.ColorToken.tile)

            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 16) {
                    SectionTitle(title: "Insulation Type")

                    HStack(spacing: 10) {
                        ForEach(["Light", "Medium", "Strong"], id: \.self) { option in
                            Button {
                                insulation = option
                            } label: {
                                Text(option)
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundStyle(insulation == option ? .white : RoomlyTheme.ColorToken.secondaryInk)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(
                                        insulation == option ? AnyShapeStyle(RoomlyTheme.ctaGradient) : AnyShapeStyle(RoomlyTheme.ColorToken.surfaceBlue),
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(18)
                .background(Color(red: 0.933, green: 0.949, blue: 0.969), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: RoomlyTheme.Shadow.blue.opacity(0.5), radius: 22, x: 0, y: 10)

                Text("You can change these room settings anytime based on your comfort or room conditions.")
                    .font(.system(size: 17, weight: .medium))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)

                Spacer()

                PremiumButton(title: "Set Data") {}
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoomlyTheme.ColorToken.background)
        }
    }

    private func syncControls() {
        guard controls.isEmpty, let roomControls = weatherViewModel.dashboard?.roomControls else { return }
        controls = roomControls
    }
}

private struct RoomControlRow: View {
    @Binding var control: RoomControl

    var body: some View {
        HStack(spacing: 12) {
            SymbolBadge(symbol: control.symbol, tint: control.isOn ? RoomlyTheme.ColorToken.primaryBlue : RoomlyTheme.ColorToken.tertiaryInk, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(control.title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(control.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: $control.isOn)
                .labelsHidden()
                .tint(RoomlyTheme.ColorToken.primaryBlue)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .roomlyCard(cornerRadius: 18)
    }
}

#Preview {
    NavigationStack {
        RoomSetupView(weatherViewModel: WeatherViewModel())
    }
}
