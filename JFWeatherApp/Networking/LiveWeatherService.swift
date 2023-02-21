//
//  LiveWeatherService.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/21/23.
//

import Foundation


enum WeatherServiceError: Swift.Error {
    case malfortedQuery
    case decodingError
    case invalidResponse
    case other(String)
}

typealias WeatherServiceResult = Result<Weather, WeatherServiceError>

protocol WeatherServiceProtocol {
    
    func fetchCoordinateWeather(
        coordinate: User.Location,
        completion: @escaping (WeatherServiceResult) -> Void
    )
    
    func fetchCityWeather(
        cityID: String,
        completion: @escaping (WeatherServiceResult) -> Void
    )
    
    
    func fetchLocationWeather(
        location: String,
        completion: @escaping (WeatherServiceResult) -> Void
    )
}


final class LiveWeatherService: NSObject, WeatherServiceProtocol {
    
    private struct Constants {
        static let baseURLString = String(describing: AppUtility.infoForKey(for: "WEATHER_BASE_URL")).trimmingCharacters(in: .whitespacesAndNewlines)
        static let weatherURLString = baseURLString + "weather"
        static let weatherAPIKey = String(describing: AppUtility.infoForKey(for: "WEATHER_API_KEY")).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private static let statusOK = 200
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceProtocol
    private let decoder = JSONDecoder()
   
    
    // MARK: - Initializer
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Methods
    
    func fetchCoordinateWeather(
        coordinate: User.Location,
        completion: @escaping (WeatherServiceResult) -> Void
    ) {
        let params: [String: String] = [
            "lat": String(coordinate.latitude),
            "lon": String(coordinate.longitude),
            "units": User.shared.tempratureUnit.rawValue,
            "appid": Constants.weatherAPIKey
        ]
        fetchWeather(params: params, completion: completion)
    }
    
    func fetchCityWeather(
        cityID: String,
        completion: @escaping (WeatherServiceResult) -> Void
    ) {
        let params: [String: String] = [
            "id": cityID,
            "units": User.shared.tempratureUnit.rawValue,
            "appid": Constants.weatherAPIKey
        ]
        fetchWeather(params: params, completion: completion)
    }
    
    func fetchLocationWeather(
        location: String,
        completion: @escaping (WeatherServiceResult) -> Void
    ) {
        let params: [String: String] = [
            "q": location,
            "units": User.shared.tempratureUnit.rawValue,
            "appid": Constants.weatherAPIKey
        ]
        fetchWeather(params: params, completion: completion)
    }

    func fetchWeather(
        params: [String: String],
        completion: @escaping (WeatherServiceResult) -> Void
    ) {
        networkService.startNetworkTask(
            query: Constants.weatherURLString,
            params: params
        ) { [weak self] weatherServiceResult in
            guard let self = self else { return }
            
            switch weatherServiceResult {
            case let .success(dataObject):
                do {
                    let weatherModel = try self.decoder.decode(Weather.self, from: dataObject)
                    completion(.success(weatherModel))
                } catch {
                    do {
                        let someCode: NoCity? = try self.decoder.decode(NoCity.self, from: dataObject)
                        if someCode != nil {
                            completion(.failure(.other(someCode!.message!)))
                        } else {
                            completion(.failure(.other(error.localizedDescription)))
                        }
                    } catch {
                        completion(.failure(.other(error.localizedDescription)))
                    }
                }

            case let .failure(networkServiceError):
                switch networkServiceError {
                case .malformedQuery:
                    completion(.failure(.malfortedQuery))
                case .invalidResponse:
                    completion(.failure(.invalidResponse))
                case let .other(localizedErrorMessage):
                    completion(.failure(.other(localizedErrorMessage)))
                }
            }
        }
    }
}



