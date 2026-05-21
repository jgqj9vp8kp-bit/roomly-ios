import SwiftUI

struct RoomSetupView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    let onSaveComplete: () -> Void
    @State private var isACOn = false
    @State private var acTemperature = ""
    @State private var isHeaterOn = false
    @State private var heaterTemperature = ""
    @State private var isFanOn = false
    @State private var fanCoolingEffect = ""
    @State private var insulation: InsulationType = .medium
    @State private var validationMessage: String?

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
            syncFromRoomSettings()
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
            setupContent
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
                RoomControlToggleRow(
                    title: "Is AC on?",
                    subtitle: "Cooling affects comfort estimate",
                    symbol: "snowflake",
                    isOn: $isACOn
                )

                if isACOn {
                    RoomTemperatureInputCard(
                        title: "AC Temperature",
                        placeholder: "Enter AC Temperature",
                        value: $acTemperature,
                        unit: weatherViewModel.temperatureUnit
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                RoomControlToggleRow(
                    title: "Is heater on?",
                    subtitle: "Heating adds indoor context",
                    symbol: "flame.fill",
                    isOn: $isHeaterOn
                )

                if isHeaterOn {
                    RoomTemperatureInputCard(
                        title: "Heater Temperature",
                        placeholder: "Enter Heater Temperature",
                        value: $heaterTemperature,
                        unit: weatherViewModel.temperatureUnit
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                RoomControlToggleRow(
                    title: "Is fan on?",
                    subtitle: "Air movement improves comfort",
                    symbol: "fan.fill",
                    isOn: $isFanOn
                )

                if isFanOn {
                    RoomTemperatureInputCard(
                        title: "Fan Effect",
                        placeholder: "Enter fan cooling effect",
                        value: $fanCoolingEffect,
                        unit: weatherViewModel.temperatureUnit
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(RoomlyTheme.ColorToken.tile)
            .animation(.spring(response: 0.42, dampingFraction: 0.88), value: isACOn)
            .animation(.spring(response: 0.42, dampingFraction: 0.88), value: isHeaterOn)
            .animation(.spring(response: 0.42, dampingFraction: 0.88), value: isFanOn)

            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 16) {
                    SectionTitle(title: "Insulation Type")

                    HStack(spacing: 10) {
                        ForEach(InsulationType.allCases) { option in
                            Button {
                                HapticFeedback.light()
                                insulation = option
                            } label: {
                                Text(option.title)
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

                if let validationMessage {
                    Text(validationMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(RoomlyTheme.ColorToken.orange)
                        .padding(.horizontal, 12)
                }

                Text("You can change these room settings anytime based on your comfort or room conditions.")
                    .font(.system(size: 17, weight: .medium))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)

                Spacer()

                PremiumButton(title: "Set Data") {
                    saveRoomSettings()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoomlyTheme.ColorToken.background)
        }
    }

    private func syncFromRoomSettings() {
        let settings = weatherViewModel.roomSettings
        isACOn = settings.isACOn
        acTemperature = settings.acTemperatureCelsius.map { formatInput(weatherViewModel.temperatureUnit.displayValue(celsius: $0)) } ?? ""
        isHeaterOn = settings.isHeaterOn
        heaterTemperature = settings.heaterTemperatureCelsius.map { formatInput(weatherViewModel.temperatureUnit.displayValue(celsius: $0)) } ?? ""
        isFanOn = settings.isFanOn
        fanCoolingEffect = settings.fanCoolingEffectCelsius.map { formatInput(weatherViewModel.temperatureUnit.displayDelta(celsius: $0)) } ?? ""
        insulation = settings.insulationType
    }

    private func saveRoomSettings() {
        do {
            let settings = try validatedRoomSettings()
            validationMessage = nil
            HapticFeedback.success()
            weatherViewModel.saveRoomSettings(settings)

            Task {
                await weatherViewModel.reload()
                onSaveComplete()
            }
        } catch {
            HapticFeedback.warning()
            validationMessage = "Enter numbers only for active room settings, or leave optional fields blank."
        }
    }

    private func validatedRoomSettings() throws -> RoomSettings {
        RoomSettings(
            isACOn: isACOn,
            acTemperatureCelsius: try optionalTemperature(acTemperature, field: "AC Temperature"),
            isHeaterOn: isHeaterOn,
            heaterTemperatureCelsius: try optionalTemperature(heaterTemperature, field: "Heater Temperature"),
            isFanOn: isFanOn,
            fanCoolingEffectCelsius: try optionalFanEffect(fanCoolingEffect),
            insulationType: insulation
        )
    }

    private func optionalTemperature(_ value: String, field: String) throws -> Double? {
        guard let number = try optionalNumber(value, field: field) else { return nil }
        return weatherViewModel.temperatureUnit.celsiusValue(from: number)
    }

    private func optionalFanEffect(_ value: String) throws -> Double? {
        guard let number = try optionalNumber(value, field: "Fan Effect") else { return nil }
        return weatherViewModel.temperatureUnit.celsiusDelta(from: number)
    }

    private func optionalNumber(_ value: String, field: String) throws -> Double? {
        let normalized = value.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        guard let number = Double(normalized), number >= 0 else {
            throw ValidationError.invalidNumber(field)
        }
        return number
    }

    private func formatInput(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(format: "%.1f", value)
    }
}

private enum ValidationError: Error {
    case invalidNumber(String)
}

private struct RoomControlToggleRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            SymbolBadge(symbol: symbol, tint: isOn ? RoomlyTheme.ColorToken.primaryBlue : RoomlyTheme.ColorToken.tertiaryInk, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(RoomlyTheme.ColorToken.primaryBlue)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .roomlyCard(cornerRadius: 18)
    }
}

private struct RoomTemperatureInputCard: View {
    let title: String
    let placeholder: String
    @Binding var value: String
    let unit: TemperatureUnit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            HStack(spacing: 10) {
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)
                    .onChange(of: value) { _, newValue in
                        let sanitized = sanitize(newValue)
                        if sanitized != newValue {
                            value = sanitized
                        }
                    }

                Text(unit.shortTitle)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(RoomlyTheme.ColorToken.surfaceBlue, in: Capsule())
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(14)
        .roomlyCard(cornerRadius: 18)
    }

    private func sanitize(_ value: String) -> String {
        var hasDecimalSeparator = false
        var result = ""

        for character in value {
            if character.isNumber {
                result.append(character)
            } else if character == "." || character == "," {
                guard !hasDecimalSeparator else { continue }
                hasDecimalSeparator = true
                result.append(".")
            }
        }

        return result
    }
}

#Preview {
    NavigationStack {
        RoomSetupView(weatherViewModel: WeatherViewModel(), onSaveComplete: {})
    }
}
