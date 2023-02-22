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
    
    // MARK: - Outlets && UI
    
    @IBOutlet var tableView: UITableView!
    
    private lazy var noDataView: NoDataView = {
        let noDataView: NoDataView = Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)?.first as! NoDataView
        noDataView.center = view.center
        noDataView.setupSelectLocatin()
        return noDataView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, 300, 20))
        searchBar.delegate = self
        searchBar.placeholder = " \(AppMessages.searchLocation)"
        searchBar.accessibilityIdentifier = "SearchBar"
        return searchBar
    }()
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "list.number"),
            style: .done,
            target: self,
            action: nil
        )
        item.menu = createContextMenu()
        return item
    }()

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var weatherViewModel: WeatherViewModel? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.reloadWeatherUI()
                self?.rightBarButtonItem.menu = self?.createContextMenu()
            }
        }
    }
    private var weatherService: WeatherServiceProtocol = LiveWeatherService(networkService: LiveNetworkService())
    
    // MARK: - Lift Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationAccess()
    }

    private func setupView() {
        showNoDataView()
        configureNavigationBar()
        tableView.dataSource = self
        Reachability.shared.startMonitoring()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}

// MARK: - UISearchBarDelegate

extension WeatherViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        closeKeyboard(isClear: false)
        userSearchedLocation(location: searchBar.text ?? "")
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        closeKeyboard(isClear: false)
        userSearchedLocation(location: searchBar.text ?? "")
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

    private func hideNoDataView() {
        noDataView.removeFromSuperview()
    }
    
    private func closeKeyboard(isClear: Bool) {
        searchBar.resignFirstResponder()
        if isClear {
            searchBar.text = ""
        }
    }
    
    private func requestLocationAccess() {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    /**
     
        Handle Location after received from Location Manager.
     
        - Parameter location: optional CLLocation
     
     */
    private func updateWeather(of location: CLLocation?) {
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
                    case let .failure(_):
                        break
                    }
                }
            )
        }
    }
}

// MARK: - UITableViewDataSource

extension WeatherViewController: UITableViewDataSource {
    func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int) -> Int
    {
        return weatherViewModel != nil ?  1 : 0
    }

    func tableView(
        _ tableView: UITableView, cellForRowAt
        _: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.WeatherCellID)
        else {
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
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            assertionFailure("Location Service restricted or denied!!")
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    internal func locationManager(
        _: CLLocationManager,
        didFailWithError error: Error
    ) {
        showAlert(message: error.localizedDescription)
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first(where: { $0.horizontalAccuracy <= 50 }) {
            updateWeather(of: location)
            manager.stopUpdatingLocation()
        } else {
            showAlert(message: AppMessages.noLocationFound)
        }
    }
    
    
}

// MARK: - LocationInputProtocol

extension WeatherViewController {

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
        if weatherViewModel != nil {
            hideNoDataView()
            closeKeyboard(isClear: true)
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
            let noHisotryAction = UIAction(
                title: AppMessages.NoWeatherHistoryMessage,
                image: UIImage(systemName: "list.number")) { _ in }
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
            ) { [weak self] action in
                guard let self = self else { return }
                self.weatherService.fetchLocationWeather(
                    location: weather.name!,
                    completion: {[weak self] weatherServiceResult in
                        guard let self = self else { return }
                        switch weatherServiceResult {
                        case let .success(weather):
                            self.weatherViewModel = WeatherViewModel(weatherModel: weather)
                        case let .failure(_):
                            break
                        }
                })
            }
        }

    
        var removeRatingAttributes = UIMenuElement.Attributes.destructive
        if historyList.count == 0 {
            removeRatingAttributes.insert(.disabled)
        }
        let deleteImage = UIImage(systemName: "trash.fill")
        let clearHistory = UIAction(
            title: AppMessages.ClearHistoryTitle,
            image: deleteImage,
            identifier: UIAction.Identifier("ClearHisotyr"),
            attributes: removeRatingAttributes
        ) { [weak self] _ in
            guard let self = self else { return }
            HistoryProvider.clearWeatherHistory()
            self.rightBarButtonItem.menu = self.createContextMenu()
        }
        menuList.append(clearHistory)

        return UIMenu(
            title: AppMessages.WeatherHistoryTitle,
            image: UIImage(systemName: "list.number"),
            identifier: .edit,
            options: .singleSelection,
            children: menuList
        )
    }
}

