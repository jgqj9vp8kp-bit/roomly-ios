import SwiftUI

struct ManualLocationView: View {
    @ObservedObject var locationViewModel: LocationViewModel
    let onSelectionComplete: () -> Void
    private let geocodingService: any GeocodingService

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [LocationSearchResult] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var searchTask: Task<Void, Never>?

    init(
        locationViewModel: LocationViewModel,
        geocodingService: any GeocodingService = OpenMeteoGeocodingService(),
        onSelectionComplete: @escaping () -> Void
    ) {
        self.locationViewModel = locationViewModel
        self.geocodingService = geocodingService
        self.onSelectionComplete = onSelectionComplete
    }

    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var visibleLocations: [ManualLocationCity] {
        guard !trimmedQuery.isEmpty else {
            return ManualLocationData.cities
        }

        return searchResults.map(ManualLocationCity.init(searchResult:))
    }

    private var shouldShowEmptyState: Bool {
        !trimmedQuery.isEmpty && !isSearching && searchError == nil && visibleLocations.isEmpty
    }

    private var shouldShowMinimumQueryState: Bool {
        !trimmedQuery.isEmpty && trimmedQuery.count < 2 && !isSearching
    }

    private var titleText: String {
        trimmedQuery.isEmpty ? "Popular Locations" : "Search Results"
    }

    var body: some View {
        ZStack {
            RoomlyBackground()

            VStack(spacing: 18) {
                header
                    .padding(.top, 14)

                searchField

                if isSearching {
                    loadingState
                } else if let searchError {
                    errorState(searchError)
                } else if shouldShowMinimumQueryState {
                    minimumQueryState
                } else if shouldShowEmptyState {
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
        .onChange(of: searchText) { _, newValue in
            scheduleSearch(for: newValue)
        }
        .onDisappear {
            searchTask?.cancel()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Choose Location")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(RoomlyTheme.ColorToken.ink)

                Text("Search worldwide cities and locations for local Weather Insights powered by saved coordinates.")
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
                SectionTitle(title: titleText)

                ForEach(visibleLocations) { city in
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

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(RoomlyTheme.ColorToken.primaryBlue)

            Text("Searching locations")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Text("Checking Open-Meteo for matching cities worldwide.")
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .roomlyCard()
    }

    private var minimumQueryState: some View {
        VStack(spacing: 10) {
            SymbolBadge(symbol: "keyboard.fill", tint: RoomlyTheme.ColorToken.primaryBlue, size: 46)

            Text("Keep typing")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Text("Enter at least two characters to search worldwide locations.")
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .roomlyCard()
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            SymbolBadge(symbol: "magnifyingglass", tint: RoomlyTheme.ColorToken.orange, size: 46)

            Text("No location found")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Text("Try a city name, region, or nearby larger location.")
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .roomlyCard()
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 10) {
            SymbolBadge(symbol: "wifi.exclamationmark", tint: RoomlyTheme.ColorToken.orange, size: 46)

            Text("Search unavailable")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(RoomlyTheme.ColorToken.ink)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)

            Button {
                scheduleSearch(for: searchText)
            } label: {
                Text("Try Again")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 38)
                    .background(RoomlyTheme.ctaGradient, in: Capsule())
            }
            .buttonStyle(PressableButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .roomlyCard()
    }

    private func scheduleSearch(for text: String) {
        searchTask?.cancel()

        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            searchError = nil
            isSearching = false
            return
        }

        guard query.count >= 2 else {
            searchResults = []
            searchError = nil
            isSearching = false
            return
        }

        searchError = nil
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 400_000_000)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    isSearching = true
                }

                let results = try await geocodingService.searchLocations(query: query)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    searchResults = results
                    searchError = nil
                    isSearching = false
                }
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    searchResults = []
                    searchError = error.localizedDescription
                    isSearching = false
                }
            }
        }
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

                Text(city.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RoomlyTheme.ColorToken.secondaryInk)
                    .lineLimit(2)
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
