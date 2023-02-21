//
//  NetworkService.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/21/23.
//

import Foundation

//protocol ErrorProtocol: LocalizedError {
//    var title: String? { get }
//    var code: Int { get }
//}
//
//struct NetworkError: ErrorProtocol {
//    var title: String?
//    var code: Int
//    var errorDescription: String? { return _description }
//    var failureReason: String? { return _description }
//
//    private var _description: String
//
//    init(title: String?, description: String, code: Int) {
//        self.title = title ?? "Error"
//        _description = description
//        self.code = code
//    }
//}

enum NetworkError: Error, LocalizedError {
    case malformedQuery
    case invalidResponse

    case other(String)

    var errorDescription: String? {
        localizedDescription
    }

    var localizedDescription: String {
        switch self {
        case .malformedQuery:
            return "malformed query"

        case .invalidResponse:
            return "invalidResponse"
            
        case let .other(message):
            return message
        }
    }
}





protocol NetworkServiceProtocol {
    func startNetworkTask(
        query: String,
        params: [String: String],
        completion: @escaping (Result<Data, NetworkError>) -> Void
    )
}

final class LiveNetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    
    static let shared = LiveNetworkService()
    private static let statusOK = 200
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration)
    }()

    // MARK: - Methods
    
    func startNetworkTask(
        query: String,
        params: [String: String],
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        
        var components = URLComponents(string: query)
        components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else {
            completion(.failure(.malformedQuery))
            return
        }
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { dataObject, response, errorObject in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == Self.statusOK,
                let receivedData = dataObject
            else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            DispatchQueue.main.async {
                if let error = errorObject {
                    completion(.failure(.other(error.localizedDescription)))
                } else {
                    completion(.success(receivedData))
                }
            }
        }
        task.resume()
    }
}
