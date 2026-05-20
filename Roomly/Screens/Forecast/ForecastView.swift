import SwiftUI

struct ForecastView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel

    var body: some View {
        WeatherInfoView(weatherViewModel: weatherViewModel)
    }
}

#Preview {
    NavigationStack {
        ForecastView(weatherViewModel: WeatherViewModel())
    }
}
