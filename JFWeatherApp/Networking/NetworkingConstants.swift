//
//  NetworkingConstants.swift
//  AUWeatherApp
//
//  Created by Anand Upadhyay on 09/02/23.
//

import Foundation

struct NetworkHelperConstants {
    static let baseURLString = String(describing: AppUtility.infoForKey(for: "WEATHER_BASE_URL")).trimmingCharacters(in: .whitespacesAndNewlines)
    static let weatherURLString = baseURLString + "weather"
    static let imageURLString = "https://openweathermap.org/img/wn/"
    static let weatherAPIKey = String(describing: AppUtility.infoForKey(for: "WEATHER_API_KEY")).trimmingCharacters(in: .whitespacesAndNewlines)
}
