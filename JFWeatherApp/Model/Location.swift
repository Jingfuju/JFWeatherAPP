//
//  Location.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/22/23.
//

import Foundation

// MARK: - Location
// TODO: - User Singleton is not well used by the JFWeatherApp, but I still plan to keep for future.
class User {
    static var shared = User()
    var tempratureUnit: TemperatureFormat = .Celsius // User's temprature Unit

    /// Location Class
    class Location {
        static var shared = Location()

        private init() {}

        var latitude: Double!
        var longitude: Double!
    }
}


enum TemperatureFormat: String {
    case Celsius = "metric"
    case Fahrenheit = "imperial"
    case Kelvin = ""
}

struct NoCity: Codable {
    let cod, message: String?
}

