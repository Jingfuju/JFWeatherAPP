//
//  WeatherViewModel.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/20/23.
//

import Foundation

// DateFormatter is computed consuming.
// Global variable is lazily initiated.
private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMMM YYYY, hh:mm a"
    dateFormatter.timeZone = TimeZone(identifier: "PST")
    return dateFormatter
}()



final class WeatherViewModel {
    
    // MARK: - Properties
    
    private let imageURLString = "https://openweathermap.org/img/wn/"
    
    private let weatherModel: Weather
    var cityLabelText: String
    var countryLabelText:  String
    var commentLabelText:  String
    var minTempLabelText:  String
    var maxTempLabelText:  String
    var dateLabelText:  String
    var weatherDescriptionLabelText:  String
    var temperatureLabelText: String
    var weatherImageURLString: String

    // MARK: - Initializer
    
    init(
        weatherModel: Weather
    ) {
        self.weatherModel = weatherModel
        
        cityLabelText = weatherModel.name ?? ""
        countryLabelText = weatherModel.sys?.country ?? ""
        
        var message = ""
        if let temperature = weatherModel.main?.temp {
            switch temperature {
            case ...15.0:
                message = AppMessages.WeatherMessage.winter.rawValue
            case 15.1 ... 25.0:
                message = AppMessages.WeatherMessage.spring.rawValue
            case 25.1...:
                message = AppMessages.WeatherMessage.summer.rawValue
            default: break
            }
        }
        commentLabelText = message
        
        minTempLabelText = String(format: "%.f°", weatherModel.main?.tempMin ?? 0)
        maxTempLabelText = String(format: "%.f°", weatherModel.main?.tempMax ?? 0)
        
        var date = ""
        if let timeData = weatherModel.timeData {
            var timestampe = timeData
            let timezoneDiff = timeData
            timestampe += timezoneDiff
            let weatherDate = Date(timeIntervalSince1970: TimeInterval(timestampe))
            date = dateFormatter.string(from: weatherDate)
        } else {
            date = dateFormatter.string(from: Date())
        }
        dateLabelText = date
        
        weatherDescriptionLabelText = weatherModel.weather?.first?.description ?? ""

        let tempUnit: NSString
        switch User.shared.tempratureUnit {
        case .Celsius:
            tempUnit = "C"
        case .Fahrenheit:
            tempUnit = "F"
        case .Kelvin:
            tempUnit = "K"
        }
        temperatureLabelText = String(format: "%.f°\(tempUnit)", weatherModel.main?.temp ?? 0)
        
        weatherImageURLString =
            "\(imageURLString)" +
            "\(weatherModel.weather?.first?.icon ?? "placeholder")" +
            "@2x.png"
    }
}
