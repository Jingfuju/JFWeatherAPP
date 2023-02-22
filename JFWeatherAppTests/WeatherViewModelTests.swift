//
//  WeatherViewModelTests.swift
//  JFWeatherAppTests
//
//  Created by Jingfu Ju on 2/22/23.
//

@testable import JFWeatherApp
import XCTest

final class WeatherViewModelTests: XCTestCase {
    
    var mockWeatherService: WeatherServiceProtocol = LiveWeatherService(networkService: MockNetworkService.shared)
    
    override func setUp() {
        super.setUp()
    }

    
    override func tearDown() {
        super.tearDown()
    }

    func test_wetherViewModelInitiallization_shouldConvertTheDataToRightFormat() {
        let expectation = self.expectation(description: "weather view model")
        var weatherModel: Weather?
        mockWeatherService.fetchCityNameWeather(
            cityName: "sample",
            completion: { result in
                if case let .success(weather) = result {
                    weatherModel = weather
                }
                expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        let viewModel = WeatherViewModel(weatherModel: weatherModel!)
        XCTAssertEqual(viewModel.cityLabelText, "Zocca")
        XCTAssertEqual(viewModel.commentLabelText, "🌞 Its Hot 🌞 Ice-cream time")
        XCTAssertEqual(viewModel.countryLabelText, "IT")
        XCTAssertEqual(viewModel.maxTempLabelText, "300°")
        XCTAssertEqual(viewModel.minTempLabelText, "298°")
        XCTAssertEqual(viewModel.dateLabelText, "Sun, 28 April 2075, 10:26 PM")
        XCTAssertEqual(viewModel.weatherDescriptionLabelText, "moderate rain")
        XCTAssertEqual(viewModel.temperatureLabelText, "298°C")
        XCTAssertEqual(viewModel.weatherImageURLString, "https://openweathermap.org/img/wn/10d@2x.png")
    }
}
