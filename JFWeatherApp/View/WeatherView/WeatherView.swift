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
    @IBOutlet var weatherImage: JFImageView!

    
    func update(with viewModel: WeatherViewModel) {
        self.cityLabel.text = viewModel.cityLabelText
        self.countryLabel.text = viewModel.countryLabelText
        self.commentLabel.text = viewModel.commentLabelText
        self.minTempLabel.text = viewModel.minTempLabelText
        self.maxTempLabel.text = viewModel.maxTempLabelText
        self.dateLabel.text = viewModel.dateLabelText
        self.weatherDescriptionLabel.text = viewModel.weatherDescriptionLabelText
        
        animate(label: temperatureLabel, with: viewModel.temperatureLabelText, options: .curveEaseIn)
        weatherImage.loadImageWithURL(URL(string:viewModel.weatherImageURLString)!)
    }
    
    private func animate(
        label: UILabel,
        with text: String,
        options: UIView.AnimationOptions
    ) {
        UIView.transition(
            with: label,
            duration: Constants.animationDuration,
            options: options,
            animations: { label.text = text },
            completion: nil
        )
    }
}
