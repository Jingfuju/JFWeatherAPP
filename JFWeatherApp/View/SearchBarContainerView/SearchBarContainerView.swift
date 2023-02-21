//
//  LocationInputView.swift
//  AUWeatherApp
//
//  Created by Anand Upadhyay on 11/02/23.
//

import UIKit


protocol SearchBarContainerViewDelegate: AnyObject {
    func userSelectedMyLocation()
    func userSearchedLocation(location: String)
    func reloadWeatherUI()
    func createContextMenu() -> UIMenu
}

class SearchBarContainerView: UIView {
    
    //MARK : - Outlets
    
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var locationSearchTextField: UITextField! {
        didSet {
            locationSearchTextField.delegate = self
            locationSearchTextField.placeholder = " \(AppMessages.searchLocation)"
            locationSearchTextField.accessibilityIdentifier = "TextLocation"
        }
    }

//    @IBOutlet var locationButton: UIButton!
    @IBOutlet var hstackInputViews: UIStackView! {
        didSet {
            hstackInputViews.isAccessibilityElement = false
        }
    }

    weak var delegate: SearchBarContainerViewDelegate?

    
    func closeKeyboard(isClear: Bool) {
        locationSearchTextField.resignFirstResponder()
        if isClear {
            locationSearchTextField.text = ""
        }
    }
    
    func bind(with weatherViewModel: WeatherViewModel?) {
        weatherViewModel?.weatherModelObserver.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.delegate?.reloadWeatherUI()
                self?.searchButton.menu = self?.delegate?.createContextMenu()
            }
        }
    }
}

// MARK: - TextField Event Handling

extension SearchBarContainerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeKeyboard(isClear: false)
        delegate?.userSearchedLocation(location: textField.text ?? "")
        return true
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        return true
    }
}
