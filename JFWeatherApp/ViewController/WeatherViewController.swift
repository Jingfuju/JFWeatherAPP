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
    
    private lazy var EmptyStateView: EmptyStateView = {
        let EmptyStateView: EmptyStateView = Bundle.main.loadNibNamed("EmptyStateView", owner: self, options: nil)?.first as! EmptyStateView
        EmptyStateView.center = view.center
        EmptyStateView.setupSelectLocatin()
        return EmptyStateView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, 300, 20))
        searchBar.delegate = self
        searchBar.placeholder = " \(AppMessages.searchLocation)"
        searchBar.accessibilityIdentifier = "SearchBar"
        return searchBar
    }()
    
    //TODO: - Need A11y file to handle the accessibilityIdentifier centralized.
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "list.number"),
            style: .done,
            target: self,
            action: nil
        )
        item.accessibilityIdentifier = "HistoryButton"
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
        loadInitialWeatherInfo()
    }

    private func setupView() {
        showEmptyStateView()
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

    private func showEmptyStateView() {
        view.addSubview(EmptyStateView)
        view.bringSubviewToFront(EmptyStateView)
    }

    private func hideEmptyStateView() {
        EmptyStateView.removeFromSuperview()
    }
    
    private func closeKeyboard(isClear: Bool) {
        searchBar.resignFirstResponder()
        if isClear {
            searchBar.text = ""
        }
    }
    
    private func loadInitialWeatherInfo() {
        if locationManager.authorizationStatus == .denied
            || locationManager.authorizationStatus == .restricted
            || locationManager.authorizationStatus == .notDetermined
        {
            locationManager.requestWhenInUseAuthorization()
        } else {
            if
                let weatherArray = HistoryProvider.readWeatherHistory(),
                    weatherArray.count > 0
            {
                weatherService.fetchCityNameWeather(
                    cityName: weatherArray[0].name!,
                    completion: {[weak self] weatherServiceResult in
                        if case let .success(weather) = weatherServiceResult {
                            self?.weatherViewModel = WeatherViewModel(weatherModel: weather)
                        }
                    }
                )
            }
        }
    }
    
    /**
     
        Handle Location Search with its coordinator after received from Location Manager.
     
        - Parameter location: optional CLLocation
     
     */
    private func updateWeather(of location: CLLocation?) {
        guard isReachable else {
            showAlert(message: "Network Error")
            return
        }
            
        tableView.isHidden = false
        tableView.showLoading(activityColor: .link)
        if let location = location {
            User.Location.shared.latitude = location.coordinate.latitude
            User.Location.shared.longitude = location.coordinate.longitude
            
            weatherService.fetchCoordinateWeather(
                coordinate: User.Location.shared,
                completion: { [weak self] weatherServiceResult in
                    guard let self = self else { return }
                    self.tableView.hideLoading()
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
    
    /**
     
        Handle Location Search with city name after received from Location Manager.
     
        - Parameter location: the String of City Name
     
     */
    private func userSearchedLocation(location: String) {
        locationManager.stopUpdatingLocation()
        
        guard isReachable else {
            showAlert(message: "Network Error")
            return
        }
            
        tableView.isHidden = false
        tableView.showLoading(activityColor: .link)
        if !location.trimmingCharacters(in: .whitespaces).isEmpty {
            weatherService.fetchCityNameWeather(
                cityName: location,
                completion: { [weak self] weatherServiceResult in
                    guard let self = self else { return }
                    self.tableView.hideLoading()
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
    
    private var isReachable: Bool {
        Reachability.shared.status == .connectedViaWiFi
        || Reachability.shared.status == .connectedViaCellular
    }
    
    private func reloadWeatherUI() {
        if weatherViewModel != nil {
            hideEmptyStateView()
            closeKeyboard(isClear: true)
        } else {
            showEmptyStateView()
        }
        tableView.reloadData()
    }
    
    private func createContextMenu() -> UIMenu {
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
                self.weatherService.fetchCityNameWeather(
                    cityName: weather.name!,
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
            identifier: UIAction.Identifier("ClearHistory"),
            attributes: removeRatingAttributes
        ) { [weak self] _ in
            guard let self = self else { return }
            HistoryProvider.clearWeatherHistory()
            self.rightBarButtonItem.menu = self.createContextMenu()
        }
        clearHistory.accessibilityIdentifier = "ClearHistory"
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
