//
//  WeatherViewModel.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/20/23.
//

import Foundation

class WeatherViewModel {
    
    // MARK: - Properties
    
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
    
    // create observers
    var locationObserver: AppObserver<String> = AppObserver("")
    let weatherModelObserver: AppObserver<Weather?> = AppObserver(nil)
    
    
    // MARK: - Initializer
    init(
        weatherModel: Weather
    ) {
        self.weatherModel = weatherModel
        weatherModelObserver.value = weatherModel
        
        cityLabelText = weatherModel.name ?? ""
        countryLabelText = weatherModel.sys?.country ?? ""
        
        var message = ""
        if let temperature = weatherModel.main?.temp {
            switch temperature {
            case ...15.0:
                message = AppMessages.WeatherMessage.Winter.rawValue
            case 15.1 ... 25.0:
                message = AppMessages.WeatherMessage.Spring.rawValue
            case 25.1...:
                message = AppMessages.WeatherMessage.Summer.rawValue
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
            let weatherDate = timestampe.fromUnixTimeStamp()
            date = " \(weatherDate?.convertToString(format: Constants.DateFormat_Long) ?? "")"
        } else {
            date = " \(Date().convertToString(format: Constants.DateFormat_Long))"
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
            "\(NetworkHelperConstants.imageURLString)" +
            "\(weatherModel.weather?.first?.icon ?? "placeholder")" +
            "@2x.png"
    }
}
