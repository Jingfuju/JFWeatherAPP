//
//  AppConstants.swift
//  AUWeatherApp
//
//  Created by Anand Upadhyay on 09/02/23.
//

import Foundation

struct Constants {
    static let LoadingIndicatorTag = 961_942
    static let NodataViewSize = 200
    static let AnimationDuration = 0.25
    static let WeatherCellId = "MyWeatherCell"
    static let MaxHistoryCount = 5
}

// TODO: - can be better implemented with Localization
enum AppMessages {
    static let defaultError: String = "Something went wrong! Please try again later."
    static let selectLocation: String = "Please select location"
    static let searchLocation: String = "Search for a city"
    static let noLocationFound: String = "No location found!"
    static let Refresh: String = "Refresh"
    static let AppTitle: String = "Weather App"
    static let searchCity: String = "Search city"
    static let WeatherHistoryTitle = "Weather History"
    static let NoWeatherHistoryMessage = "No history found"
    static let ClearHistoryTitle = "Clear History"

    enum WeatherMessage: String {
        case Winter = "❄️ Cool ❄️ Grab a Cappacino"
        case Summer = "🌞 Its Hot 🌞 Ice-cream time"
        case Monsoon = "🌧️ Its Raining 🌧️ Lets dance"
        case Spring = "🌼 Relax 🌼 Ride a bike"
    }
}

enum AppKeys {
    static let WeatherList = "WeatherList"
}
