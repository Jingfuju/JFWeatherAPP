//
//  Weather.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/21/23.
//

import Foundation

// MARK: - Weather

struct Weather: Codable {
    let coordinate: Coordinate?
    let weather: [WeatherElement]?
    let wind: Wind?
    let clouds: Clouds?
    let sys: Sys?
    let main: Main?
    let base: String?
    let visibility: Int?
    let timeData: Int?
    let timeZone: Int?
    let id: Int?
    let name: String?
    let cod: Int?
    
    enum CodingKeys: String, CodingKey {
        case coordinate = "coord"
        case weather
        case wind
        case clouds
        case sys
        case main
        case base
        case visibility
        case timeData = "dt"
        case timeZone = "timezone"
        case id
        case name
        case cod
    }
}

// MARK: - Coordinator

struct Coordinate: Codable {
    let longitude: Double?
    let latitude: Double?

    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

// MARK: - Main

struct Main: Codable {
    let temp: Double?
    let feelsLike: Double?
    let tempMin: Double?
    let tempMax: Double?
    let pressure: Int?
    let humidity: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

// MARK: - Sys

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

// MARK: - WeatherElement

struct WeatherElement: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}


// MARK: - Clouds

struct Clouds: Codable {
    let all: Int?
}


// MARK: - Wind

struct Wind: Codable {
    let speed: Double?
    let deg: Int?
}

