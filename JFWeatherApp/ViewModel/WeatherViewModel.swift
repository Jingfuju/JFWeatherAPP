//
//  WeatherViewModel.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/20/23.
//

import Foundation

class WeatherViewModel {
    private let apiService: NetworkServiceProtocol
    init(apiService: NetworkServiceProtocol = NetworkHelper()) {
        self.apiService = apiService
    }

    // create observers
    var location: AppObserver<String> = AppObserver("")
    let weatherModel: AppObserver<Weather?> = AppObserver(nil)

    /// Fetch Weather
    /// - Parameters:
    ///   - params: Parameters q:Location, lat: lattitude, log: longitutude, appid: API key, unit: Metric: Celsius, Imperial: Fahrenheit default is Kelvin
    ///   - complete: Completion block with Result<AppObserver<Weather?>, Error>
    func fetchWeather(
        params: [String: String],
        complete: @escaping (Result<AppObserver<Weather?>, Error>) -> Void
    ) {
        apiService.startNetworkTask(urlStr: NetworkHelperConstants.weatherURL, params: params) { result in
            switch result {
            case let .success(dataObject):
                do {
//                    let convertedString = String(data: dataObject ?? Data(), encoding: .utf8)
//                    print("Response: \(convertedString ?? "No Data")")
                    let decoderObject = JSONDecoder()
                    self.weatherModel.value = try decoderObject.decode(Weather.self, from: dataObject!)
                    complete(.success(self.weatherModel))
                } catch {
                    do {
                        self.weatherModel.value = nil
                        let decoderObject = JSONDecoder()
                        let someCode: NoCity? = try decoderObject.decode(NoCity.self, from: dataObject!)
                        if someCode != nil {
                            print(someCode!.message as Any)
                            complete(.failure(.other(someCode!.message!)))
                        } else {
                            complete(.failure(.other(error.localizedDescription)))
                        }
                    } catch {
                        complete(.failure(.other(error.localizedDescription)))
                    }
                }

            case let .failure(error):
                self.weatherModel.value = nil
                complete(.failure(.other(error.localizedDescription)))
            }
        }
    }
}
