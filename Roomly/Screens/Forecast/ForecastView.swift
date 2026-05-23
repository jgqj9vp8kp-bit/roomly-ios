import SwiftUI

struct ForecastView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel

    var body: some View {
        WeatherInfoView(weatherViewModel: weatherViewModel, showsBackButton: false)
    }
}

#Preview {
    NavigationStack {
        ForecastView(weatherViewModel: WeatherViewModel())
    }
}
