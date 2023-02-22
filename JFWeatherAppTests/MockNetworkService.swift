//
//  MockNetworkService.swift
//  JFWeatherAppTests
//
//  Created by Jingfu Ju on 2/22/23.
//

@testable import JFWeatherApp
import Foundation


final class MockNetworkService: NetworkServiceProtocol {
    
    static let shared = MockNetworkService()

    /**
        
     Load as JSON from file
     
     - Parameter fileName: JSON file to load data from
     - Returns: data
     
     */
    
    private static func loadFromJSON(filename fileName: String) -> Data {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let dataObject = try Data(contentsOf: url)
                return dataObject
            } catch {
                assertionFailure("error")
            }
        }
        return Data()
    }
    
    
    func startNetworkTask(
        query: String,
        params: [String : String],
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async {
            let data = MockNetworkService.loadFromJSON(filename: "SingleWeather")
                print(data)
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
    }
}
