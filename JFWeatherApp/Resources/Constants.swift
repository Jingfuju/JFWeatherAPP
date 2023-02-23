//
//  Constants.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/22/23.
//

import Foundation

struct Constants {
    static let loadingIndicatorTag = 961_942
    static let emptyStateViewSize = 200
    static let animationDuration = 0.25
    static let weatherCellID = "MyWeatherCell"
    static let maxHistoryCount = 5
}

// TODO: - can be better implemented with Localization
enum AppMessages {
    static let defaultError: String = "Something went wrong! Please try again later."
    static let selectLocation: String = "Please select location"
    static let searchLocation: String = "Search for a city"
    static let noLocationFound: String = "No location found!"
    static let checkCityName: String = "Please check the city name spelling！"
    static let refresh: String = "Refresh"
    static let appTitle: String = "Weather App"
    static let searchCity: String = "Search city"
    static let weatherHistoryTitle = "History"
    static let noWeatherHistoryMessage = "No history found"
    static let clearHistoryTitle = "Clear History"

    enum WeatherMessage: String {
        case winter = "❄️ Cool ❄️ Grab a Cappacino"
        case summer = "🌞 Its Hot 🌞 Ice-cream time"
        case monsoon = "🌧️ Its Raining 🌧️ Lets dance"
        case spring = "🌼 Relax 🌼 Ride a bike"
    }
}

enum AppKeys {
    static let weatherList = "WeatherList"
}

