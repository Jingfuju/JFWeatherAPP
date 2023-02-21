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

    // MARK: - Lift Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationAccess()
    }

    // MARK: - Setup UI , Reload and Observer Binding

    func setupView() {
        
        showNoDataView()
        self.navigationController?.isNavigationBarHidden = true


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
        //        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name:  Reachability.connectionStatusHasChangedNotification, object: nil)
    }

    // MARK: - Error / No Data Handling

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

    
    private lazy var noDataView: NoDataView = {
        let noDataView: NoDataView = Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)?.first as! NoDataView
        noDataView.center = view.center
        noDataView.setupSelectLocatin()
        return noDataView
    }()

    
    func showNoDataView() {
        view.addSubview(noDataView)
        view.bringSubviewToFront(noDataView)
    }

    /// Hide No Data View
    func hideNoDataView() {
        noDataView.removeFromSuperview()
    }
}

// MARK: - Weather History Menu

extension WeatherViewController {
    
   
    func createContextMenu() -> UIMenu {
        var menuList = [UIAction]()
        guard let historyList = HistoryProvider.readWeatherHistory() else {
            let noHisotryAction = UIAction(title: AppMessages.NoWeatherHistoryMessage, image: UIImage(systemName: "list.number")) { _ in
            }
            return UIMenu(title: AppMessages.WeatherHistoryTitle, image: nil, identifier: .edit, options: .singleSelection, children: [noHisotryAction])
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
            getWeatherForAvailableLocation(location: User.Location.shared)
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

    private func locationManager(
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
            getWeatherForSearchLocation(location: location)
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
}

// MARK: - Web Service Calling

extension WeatherViewController {
    
    /// Get Weather information for User's Location as in Lat & Lon
    /// - Parameter location: user's location
    func getWeatherForAvailableLocation(location: User.Location) {
        let params: [String: String] = [
            "lat": String(location.latitude),
            "lon": String(location.longitude),
            "units": User.shared.tempratureUnit.rawValue,
            "appid": NetworkHelperConstants.weatherAPIKey
        ]
        fetchWeather(params: params)
    }
    
    func getWeatherForSelectedCity(cityId: String) {
        let params: [String: String] = [
            "id": cityId,
            "units": User.shared.tempratureUnit.rawValue,
            "appid": NetworkHelperConstants.weatherAPIKey
        ]
        fetchWeather(params: params)
    }

   
    func getWeatherForSearchLocation(location: String) {
        let params: [String: String] = [
            "q": location,
            "units": User.shared.tempratureUnit.rawValue,
            "appid": NetworkHelperConstants.weatherAPIKey
        ]
        fetchWeather(params: params)
    }

    
    func fetchWeather(params: [String: String]) {
        if Reachability.shared.status == .connectedViaWiFi || Reachability.shared.status == .connectedViaCellular {
            tableView.isHidden = false
            tableView.showLoading(activityColor: .link)
            fetchWeather(params: params) { result in
                self.tableView.hideLoading()
                switch result {
                case .success:
                    _ = HistoryProvider.writeWeatherHistory(weather: self.weatherViewModel?.weatherModelObserver.value)
                // No need to handle UI Updates here as whenever a new weather will be updated and the binding will take place and trigger UI Update
                    
                    self.tableView.reloadData()
                    self.hideNoDataView()
                case let .failure(error):
                    self.showAlert(message: error.localizedDescription)
                }
            }
        } else {
            showAlert(message: Error.network.localizedDescription)
        }
    }
    
    /// Fetch Weather
    /// - Parameters:
    ///   - params: Parameters q:Location, lat: lattitude, log: longitutude, appid: API key, unit: Metric: Celsius, Imperial: Fahrenheit default is Kelvin
    ///   - complete: Completion block with Result<AppObserver<Weather?>, Error>
    func fetchWeather(
        params: [String: String],
        complete: @escaping (Result<AppObserver<Weather?>, Error>) -> Void
    ) {
        NetworkHelper().startNetworkTask(
            urlStr: NetworkHelperConstants.weatherURLString,
            params: params
        ) { result in
            switch result {
            case let .success(dataObject):
                do {
                    let decoderObject = JSONDecoder()
                    let weatherModel = try decoderObject.decode(Weather.self, from: dataObject!)
                    self.weatherViewModel = WeatherViewModel(weatherModel: weatherModel)
                    complete(.success(self.weatherViewModel?.weatherModelObserver ?? AppObserver(nil)))
                } catch {
                    do {
                        self.weatherViewModel?.weatherModelObserver.value = nil
                        let decoderObject = JSONDecoder()
                        let someCode: NoCity? = try decoderObject.decode(NoCity.self, from: dataObject!)
                        if someCode != nil {
                            complete(.failure(.other(someCode!.message!)))
                        } else {
                            complete(.failure(.other(error.localizedDescription)))
                        }
                    } catch {
                        complete(.failure(.other(error.localizedDescription)))
                    }
                }

            case let .failure(error):
                self.weatherViewModel?.weatherModelObserver.value = nil
                complete(.failure(.other(error.localizedDescription)))
            }
        }
    }
}
