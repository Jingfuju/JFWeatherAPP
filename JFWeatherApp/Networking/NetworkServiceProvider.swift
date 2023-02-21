//
//  NetworkServiceProvider.swift
//  AUWeatherApp
//
//  Created by Anand Upadhyay on 09/02/23.
//

import Foundation

protocol ErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

struct NetworkError: ErrorProtocol {
    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }

    private var _description: String

    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        _description = description
        self.code = code
    }
}

enum Error: Swift.Error, LocalizedError {
    case badUrl
    case network
    case dataCorrupted
    case apiKeyIsMissing

    case other(String)

    var errorDescription: String? {
        localizedDescription
    }

    var localizedDescription: String {
        switch self {
        case .badUrl:
            return "Wrong city"

        case .network:
            return "Network error"

        case .dataCorrupted:
            return "Invalid data format"

        case .apiKeyIsMissing:
            return "Insert your API key"

        case let .other(message):
            return message
        }
    }
}


struct NetworkHelperConstants {
    static let baseURLString = String(describing: AppUtility.infoForKey(for: "WEATHER_BASE_URL")).trimmingCharacters(in: .whitespacesAndNewlines)
    static let weatherURLString = baseURLString + "weather"
    static let imageURLString = "https://openweathermap.org/img/wn/"
    static let weatherAPIKey = String(describing: AppUtility.infoForKey(for: "WEATHER_API_KEY")).trimmingCharacters(in: .whitespacesAndNewlines)
}


protocol NetworkServiceProtocol {
    func startNetworkTask(urlStr: String, params: [String: String], resultHandler: @escaping (Result<Data?, Error>) -> Void)
}

class NetworkHelper: NetworkServiceProtocol {
    static let shared = NetworkHelper()

    func startNetworkTask(
        urlStr: String,
        params: [String: String],
        resultHandler: @escaping (Result<Data?, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async {
            guard let urlComp = NSURLComponents(string: urlStr) else {
                resultHandler(.failure(.badUrl))
                return
            }

            if params.count > 0 {
                var items = [URLQueryItem]()
                for (key, value) in params {
                    items.append(URLQueryItem(name: key, value: value))
                }
                items = items.filter { !$0.name.isEmpty }
                if !items.isEmpty {
                    urlComp.queryItems = items
                }
            }
            let urlRequest = URLRequest(url: urlComp.url!)

            URLSession.shared.dataTask(with: urlRequest) { dataObject, _, errorObject in
                DispatchQueue.main.async {
                    if let error = errorObject {
                        resultHandler(.failure(.other(error.localizedDescription)))
                    } else {
                        resultHandler(.success(dataObject))
                    }
                }
            }.resume()
        }
    }
}
