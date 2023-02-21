//
//  WeatherView.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/20/23.
//

import Foundation
import UIKit


class WeatherView: UIView {
    
    // MARK: - Outlets
    
    @IBOutlet private var cityLabel: UILabel!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var commentLabel: UILabel!
    @IBOutlet private var minTempLabel: UILabel!
    @IBOutlet private var maxTempLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var weatherDescriptionLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet var weatherImage: MyExtendedImage!

    
    func update(with viewModel: WeatherViewModel) {
        
    }
    
    
    func update(with weather: Weather) {
        let temperature = weather.main?.temp
        switch temperature! {
        case ...15.0:
            commentLabel.text = AppMessages.WeatherMessage.Winter.rawValue
        case 15.1 ... 25.0:
            commentLabel.text = AppMessages.WeatherMessage.Spring.rawValue
        case 25.1...:
            commentLabel.text = AppMessages.WeatherMessage.Summer.rawValue
        default: break
        }

        if let iconId = weather.weather?.first?.icon {
            weatherImage.loadImageWithUrl(URL(string: "\(NetworkHelperConstants.imageURL)\(iconId)@2x.png")!)
        }

        setupDateLabel(with: weather)
        minTempLabel.text = String(format: "%.f°", weather.main?.tempMin ?? 0)
        maxTempLabel.text = String(format: "%.f°", weather.main?.tempMax ?? 0)
        cityLabel.text = weather.name
        countryLabel.text = weather.sys?.country
        weatherDescriptionLabel.text = weather.weather?.first?.description

        let tempUnit: NSString
        switch User.shared.tempratureUnit {
        case .Celsius:
            tempUnit = "C"
        case .Fahrenheit:
            tempUnit = "F"
        case .Kelvin:
            tempUnit = "K"
        }
        animate(text: String(format: "%.f°\(tempUnit)", weather.main?.temp ?? 0), with: .curveEaseIn)
    }

    func setupDateLabel(with weather: Weather) {
        let date: String
        if weather.timeData != nil {
            var timestampe = weather.timeData ?? 0
            let timezoneDiff = weather.timeZone ?? 0
            timestampe += timezoneDiff
            let weatherDate = timestampe.fromUnixTimeStamp()
            date = " \(weatherDate?.convertToString(format: Constants.DateFormat_Long) ?? "")"
        } else {
            date = " \(Date().convertToString(format: Constants.DateFormat_Long))"
        }
        dateLabel.text = date
    }

    
    private func animate(text: String, with options: UIView.AnimationOptions) {
        UIView.transition(
            with: temperatureLabel,
            duration: Constants.AnimationDuration,
            options: options,
            animations: { [weak self] in
                self?.temperatureLabel.text = text
            },
            completion: nil
        )
    }
}
