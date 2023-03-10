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
    case invalidResponse(String)
    case other(String)
}

typealias WeatherServiceResult = Result<Weather, WeatherServiceError>

protocol WeatherServiceProtocol {
    
    /**
     
    Fetch the weather infomation by coorinate.
     
    - Parameters:
        - coordinate:  the coorinate information.
        - completion: @escaping closure with Result type as input value.
        success data is Weather data model and failure data is binded to the WeatherServiceError.
                                    
     */
    func fetchCoordinateWeather(
        coordinate: User.Location,
        completion: @escaping (WeatherServiceResult) -> Void
    )
    
    /**
     
    Fetch the weather infomation by cityID String.
     
    - Parameters:
        - cityID:  the cityID String.
        - completion: @escaping closure with Result type as input value.
        success data is Weather data model and failure data is binded to the WeatherServiceError.
                                    
     */
    func fetchCityWeather(
        cityID: String,
        completion: @escaping (WeatherServiceResult) -> Void
    )
    
    
    /**
     
    Fetch the weather infomation by cityName String.
     
    - Parameters:
        - cityName:  the cityID String.
        - completion: @escaping closure with Result type as input value.
        success data is Weather data model and failure data is binded to the WeatherServiceError.
                                    
     */
    func fetchCityNameWeather(
        cityName: String,
        completion: @escaping (WeatherServiceResult) -> Void
    )
}


final class LiveWeatherService: NSObject, WeatherServiceProtocol {
    
    private struct Constants {
        static let baseURLString = "https://api.openweathermap.org/data/2.5/"
        static let weatherURLString = baseURLString + "weather"
        static let weatherAPIKey = "579ca2cb78c7464b12c279a722775c58"
    }
    private static let statusOK = 200
    private static let statusPageNotFound = 404
    
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
        ]
        fetchWeather(params: params, completion: completion)
    }
    
    func fetchCityWeather(
        cityID: String,
        completion: @escaping (WeatherServiceResult) -> Void
    ) {
        let params: [String: String] = ["id": cityID]
        fetchWeather(params: params, completion: completion)
    }
    
    func fetchCityNameWeather(
        cityName: String,
        completion: @escaping (WeatherServiceResult) -> Void
    ) {
        let params: [String: String] = [ "q": cityName]
        fetchWeather(params: params, completion: completion)
    }

    private func fetchWeather(
        params: [String: String],
        completion: @escaping (WeatherServiceResult) -> Void
    ) {
        var params = params
        params["units"] = User.shared.tempratureUnit.rawValue
        params["appid"] = Constants.weatherAPIKey
        
        networkService.startNetworkTask(
            query: Constants.weatherURLString,
            params: params
        ) { [weak self] weatherServiceResult in
            guard let self = self else { return }
            
            switch weatherServiceResult {
            case let .success(dataObject):
                do {
                    let weatherModel = try self.decoder.decode(Weather.self, from: dataObject)
                    HistoryProvider.writeWeatherHistory(weather: weatherModel)
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
                case let .invalidResponse(code):
                    completion(.failure(.invalidResponse(code)))
                case let .other(localizedErrorMessage):
                    completion(.failure(.other(localizedErrorMessage)))
                }
            }
        }
    }
}



