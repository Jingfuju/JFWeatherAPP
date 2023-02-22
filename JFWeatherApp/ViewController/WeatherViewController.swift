//
//  WeatherViewController.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/20/23.
//

import CoreLocation
import Foundation
import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    // MARK: - Private Properties

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var weatherViewModel: WeatherViewModel?
    let searchBarContainerView: SearchBarContainerView = .fromNib()
    var weatherService: WeatherServiceProtocol = LiveWeatherService(networkService: LiveNetworkService())
    
    // MARK: - UI
    
    private lazy var noDataView: NoDataView = {
        let noDataView: NoDataView = Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)?.first as! NoDataView
        noDataView.center = view.center
        noDataView.setupSelectLocatin()
        return noDataView
    }()


    // MARK: - Lift Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationAccess()
    }

    func setupView() {
        showNoDataView()
        self.navigationController?.isNavigationBarHidden = false

//        self.navigationController
        
        tableView.dataSource = self
        tableView.tableHeaderView = searchBarContainerView
        
        
        searchBarContainerView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: 0
        )
        
        searchBarContainerView.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: 0
        )
        
        searchBarContainerView.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: 0
        )
        searchBarContainerView.delegate = self
        searchBarContainerView.bind(with: weatherViewModel)
        Reachability.shared.startMonitoring()
    }
}

// MARK: - Privates
private extension WeatherViewController {
    private func showAlert(message: String) {
        let alertController = UIAlertController(
            title: AppMessages.AppTitle,
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Okay", style: .default)
        alertController.addAction(action)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }

    private func showNoDataView() {
        view.addSubview(noDataView)
        view.bringSubviewToFront(noDataView)
    }

    /// Hide No Data View
    private func hideNoDataView() {
        noDataView.removeFromSuperview()
    }
}

// MARK: - UITableViewDataSource

extension WeatherViewController: UITableViewDataSource {
    func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int) -> Int
    {
        if weatherViewModel?.weatherModelObserver.value?.weather != nil {
            return 1
        } else { return 0 }
    }

    func tableView(
        _ tableView: UITableView, cellForRowAt
        _: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.WeatherCellId
        ) else {
            return UITableViewCell()
        }
        let weatherView = cell.contentView.viewWithTag(1) as! WeatherView
        if let viewModel = weatherViewModel {
            weatherView.update(with: viewModel)
        }
        return cell
    }
}


// MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    /// handle Location after received from Location Manager
    /// - Parameter location: Location
    func performLocationUpdate(location: CLLocation?) {
        if let location = location {
            User.Location.shared.latitude = location.coordinate.latitude
            User.Location.shared.longitude = location.coordinate.longitude
            
            weatherService.fetchCoordinateWeather(
                coordinate: User.Location.shared,
                completion: { [weak self] weatherServiceResult in
                    guard let self = self else { return }
                    switch weatherServiceResult {
                    case let .success(weather):
                        self.weatherViewModel = WeatherViewModel(weatherModel: weather)
                        self.reloadWeatherUI()
                    case let .failure(_):
                        break
                    }
                }
            )
        }
    }

    func requestLocationAccess() {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Sorry, restricted")
        case .denied:
            print("Sorry, denied")
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Some location updates can be invalid or have insufficient accuracy.
        // Find the first location that has sufficient horizontal accuracy.
        // If the manager's desiredAccuracy is one of kCLLocationAccuracyNearestTenMeters,
        // kCLLocationAccuracyHundredMeters, kCLLocationAccuracyKilometer, or kCLLocationAccuracyThreeKilometers
        // then you can use $0.horizontalAccuracy <= manager.desiredAccuracy. Otherwise enter the number of meters desired.
        if let location = locations.first(where: { $0.horizontalAccuracy <= 50 }) {
            performLocationUpdate(location: locationManager.location)
            // stop updating Location if you don't need any more updates
            manager.stopUpdatingLocation()
        } else {
            showAlert(message: AppMessages.noLocationFound)
        }
    }

    internal func locationManager(
        _: CLLocationManager,
        didFailWithError error: Error
    ) {
        showAlert(message: error.localizedDescription)
    }
}

// MARK: - LocationInputProtocol

extension WeatherViewController: SearchBarContainerViewDelegate {
    
    func userSelectedMyLocation() {
        requestLocationAccess()
    }

    func userSearchedLocation(location: String) {
        locationManager.stopUpdatingLocation()
        if !location.trimmingCharacters(in: .whitespaces).isEmpty {
            weatherService.fetchLocationWeather(
                location: location,
                completion: { [weak self] weatherServiceResult in
                    guard let self = self else { return }
                    switch weatherServiceResult {
                    case let .success(weather):
                        self.weatherViewModel = WeatherViewModel(weatherModel: weather)
                        self.reloadWeatherUI()
                    case let .failure(_):
                        break
                    }
                }
            )
        } else {
            showAlert(message: AppMessages.selectLocation)
        }
    }
    
    func reloadWeatherUI() {
        if weatherViewModel?.weatherModelObserver.value?.weather != nil {
            hideNoDataView()
            searchBarContainerView.closeKeyboard(isClear: true)
        } else {
            showNoDataView()
        }
        tableView.reloadData()
    }
    
    func createContextMenu() -> UIMenu {
        var menuList = [UIAction]()
        guard
            let historyList = HistoryProvider.readWeatherHistory()
        else {
            let noHisotryAction = UIAction(title: AppMessages.NoWeatherHistoryMessage, image: UIImage(systemName: "list.number")) { _ in
            }
            return UIMenu(
                title: AppMessages.WeatherHistoryTitle,
                image: nil,
                identifier: .edit,
                options: .singleSelection,
                children: [noHisotryAction]
            )
        }

        menuList = historyList.enumerated().map { index, weather in
            UIAction(
                title: weather.name!,
                identifier: UIAction.Identifier("HistoryMenu\(index + 1)")
            ) { action in
                self.weatherViewModel?.weatherModelObserver.value = weather
            }
        }

        // Add Clear History Action
        var removeRatingAttributes = UIMenuElement.Attributes.destructive
        // enable or disable action based on the count
        if historyList.count == 0 {
            removeRatingAttributes.insert(.disabled)
        }
        let deleteImage = UIImage(systemName: "trash.fill")
        let clearHistory = UIAction(
            title: AppMessages.ClearHistoryTitle,
            image: deleteImage,
            identifier: UIAction.Identifier("ClearHisotyr"),
            attributes: removeRatingAttributes
        ) { _ in
            HistoryProvider.clearWeatherHistory()
            self.searchBarContainerView.searchButton.menu = self.createContextMenu()
        }
        menuList.append(clearHistory)

        return UIMenu(
            title: AppMessages.WeatherHistoryTitle,
            image: UIImage(systemName: "list.number"),
            identifier: .edit, options: .singleSelection,
            children: menuList
        )
    }
}

