import SwiftUI

struct ManualLocationView: View {
    @ObservedObject var locationViewModel: LocationViewModel
    let onSelectionComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredCities: [ManualLocationCity] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return ManualLocationData.cities
        }

        return ManualLocationData.cities.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ZStack {
            RoomlyBackground()

            VStack(spacing: 18) {
                header
                    .padding(.top, 14)

                searchField

                if filteredCities.isEmpty {
                    emptyState
                } else {
                    cityList
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, RoomlyTheme.Spacing.screenHorizontal)
            .padding(.bottom, 24)
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Choose Location")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text("Select a city for local Weather Insights powered by your saved coordinates.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            IconButton(symbol: "xmark") {
                dismiss()
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)

            TextField("Search city", text: $searchText)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 54)
        .background(RoomlyTheme.ColorToken.surface, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .stroke(RoomlyTheme.ColorToken.border, lineWidth: 1)
        )
        .shadow(color: RoomlyTheme.Shadow.soft.opacity(0.8), radius: 14, x: 0, y: 6)
    }

    private var cityList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(filteredCities) { city in
                    Button {
                        HapticFeedback.success()
                        locationViewModel.selectManualCity(city)
                        dismiss()
                        onSelectionComplete()
                    } label: {
                        ManualLocationRow(
                            city: city,
                            isSelected: locationViewModel.selectedManualCity == city && locationViewModel.locationSource == .manual
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            SymbolBadge(symbol: "magnifyingglass", tint: RoomlyTheme.ColorToken.orange, size: 46)

            Text("No city found")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Text("Try one of the suggested cities for this prototype.")
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .roomlyCard()
    }
}

private struct ManualLocationRow: View {
    let city: ManualLocationCity
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            SymbolBadge(
                symbol: isSelected ? "checkmark.location.fill" : "mappin.circle.fill",
                tint: isSelected ? RoomlyTheme.ColorToken.green : RoomlyTheme.ColorToken.primaryBlue,
                size: 42
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(city.name)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text(city.coordinate.formatted)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(RoomlyTheme.ColorToken.tertiaryInk)
        }
        .padding(14)
        .background(
            isSelected ? RoomlyTheme.ColorToken.tileSelected : RoomlyTheme.ColorToken.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? RoomlyTheme.ColorToken.primaryBlue.opacity(0.35) : RoomlyTheme.ColorToken.border, lineWidth: 1)
        )
    }
}

#Preview {
    ManualLocationView(locationViewModel: LocationViewModel(), onSelectionComplete: {})
}
