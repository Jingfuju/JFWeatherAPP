//
//  WeatherModelTests.swift
//  JFWeatherAppTests
//
//  Created by Jingfu Ju on 2/22/23.
//

@testable import JFWeatherApp
import XCTest

final class WeatherModelTests: XCTestCase {
    
    var mockWeatherService: WeatherServiceProtocol = LiveWeatherService(networkService: MockNetworkService.shared)
    
    override func setUp() {
        super.setUp()
    }

    
    override func tearDown() {
        super.tearDown()
    }

    func test_weatherDataServiceDecoding_shouldReturnRightData() {
        let expectation = self.expectation(description: "weather view model")
        var dateModel: Weather?
        mockWeatherService.fetchCityNameWeather(
            cityName: "sample",
            completion: { result in
                if case let .success(weather) = result {
                    dateModel = weather
                }
                expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        guard let dateModel = dateModel else {
            XCTAssertFalse(true)
            return
        }
        XCTAssertEqual(dateModel.cod ?? 0, 200)
        XCTAssertEqual(dateModel.clouds?.all ?? 0, 100)
        XCTAssertEqual(dateModel.coordinate?.latitude, 44.34)
        XCTAssertEqual(dateModel.coordinate?.longitude, 10.99)
        XCTAssertEqual(dateModel.name?.count, 5)
        XCTAssertEqual(dateModel.weather?.capacity ?? 0, 1)
        XCTAssertEqual(dateModel.id ?? 0, 3163858)
    }
}
