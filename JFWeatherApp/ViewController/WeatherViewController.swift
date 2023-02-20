//
//  WeatherViewController.swift
//  AUWeatherApp
//
//  Created by Anand Upadhyay on 11/02/23.
//

import UIKit
import Foundation
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var tblWeather: UITableView!
    @IBOutlet weak var barBtnHistory: UIBarButtonItem!{
        didSet{
            barBtnHistory.primaryAction = nil
            barBtnHistory.accessibilityIdentifier = "HistoryButton"
            barBtnHistory.menu = self.createContextMenu()
        }
    }
    
    //MARK: Private Properties
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    var weatherVM = WeatherViewModel()
    let locationPickView: LocationInputView = .fromNib()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Setup UI , Reload and Observer Binding
    func setupView(){
        //No Data View
        showNoDataView()
        //Title
        self.title = AppMessages.AppTitle
        //Tableview
        tblWeather.adjustSeperatorInsent()
        tblWeather.dataSource = self
        //Header View
        locationPickView.delegate = self
        tblWeather.tableHeaderView = locationPickView
        //Location Manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy =  kCLLocationAccuracyBest
        //Binding Observer
        bindWeatherModel()
        //Reachability
        Reachability.shared.startMonitoring()
        //        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name:  Reachability.connectionStatusHasChangedNotification, object: nil)
    }
    
    /// Reload Weather UI
    func reloadWeatherUI(){
        if weatherVM.weatherModel.value?.weather != nil {
            //Found Weather
            hideNoDataView()
            locationPickView.closeKeyboard(isClear: true)
        }else{
            //Not Found
            showNoDataView()
        }
        tblWeather.reloadData()
    }
    
    /// Binding of Observer
    func bindWeatherModel(){
        weatherVM.weatherModel.bind { [weak self] newModel in
            DispatchQueue.main.async {
                self?.reloadWeatherUI()
                self?.barBtnHistory.menu =  self?.createContextMenu()
            }
        }
    }
    
    // MARK: - Error / No Data Handling
    
    /// Show Common Alert
    /// - Parameter message: Alert Message
    func showAlert(message: String){
        openAlert(title: AppMessages.AppTitle, message: message,  alertStyle: .alert, actionTitles: ["Okay"], actionStyles: [.default],actions: [
            { _ in
            }
        ])
    }
    
    /// No Data Label
    private lazy var nodataView: NoDataView = {
        let ndV: NoDataView = Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)?.first as! NoDataView
        ndV.center = view.center
        ndV.setupSelectLocatin()
        return ndV
    }()
    
    /// Show No Data View
    func showNoDataView(){
        view.addSubview(nodataView)
        view.bringSubviewToFront(nodataView)
    }
    
    /// Hide No Data View
    func hideNoDataView() {
        nodataView.removeFromSuperview()
    }
}

//MARK: - Weather History Menu
extension WeatherViewController{
    
    /// Create Context Menu for History Button
    /// - Returns: UIMenu menu list
    func createContextMenu() -> UIMenu {
        
        var menuList = [UIAction]()
        guard let historyList = HistoryProvider.readWeatherHistory() else{
            let noHisotryAction = UIAction(title: AppMessages.NoWeatherHistoryMessage, image: UIImage(systemName: "list.number")) { _ in
            }
            return UIMenu(title: AppMessages.WeatherHistoryTitle, image: nil, identifier: .edit, options: .singleSelection, children: [noHisotryAction])
        }
        
        menuList = historyList.enumerated().map { index,weather in
            return UIAction(
                title: weather.name!,
                identifier: UIAction.Identifier("HistoryMenu\(index + 1)")) { action in
                    print(action.title)
                    self.weatherVM.weatherModel.value = weather
                }
        }
        
        //Add Clear History Action
        var removeRatingAttributes = UIMenuElement.Attributes.destructive
        //enable or disable action based on the count
        if historyList.count == 0 {
          removeRatingAttributes.insert(.disabled)
        }
        let deleteImage = UIImage(systemName: "trash.fill")
        let clearHistory = UIAction(
          title: AppMessages.ClearHistoryTitle,
          image: deleteImage,
          identifier: UIAction.Identifier("ClearHisotyr"),
          attributes: removeRatingAttributes) { _ in
              HistoryProvider.clearWeatherHistory()
              self.barBtnHistory.menu = self.createContextMenu()
        }
        menuList.append(clearHistory)
        
        return UIMenu(title: AppMessages.WeatherHistoryTitle, image: UIImage(systemName: "list.number"), identifier: .edit, options: .singleSelection, children: menuList)
    }
}



extension WeatherViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weatherVM.weatherModel.value?.weather != nil {
            return 1
        }else{ return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.WeatherCellId)  else {
            return UITableViewCell()
        }
        
        //Access the weather view from Cell and provide weather information to update ui
        let weatherView = cell.contentView.viewWithTag(1) as! WeatherView
        if weatherVM.weatherModel.value?.weather != nil {
            let weather = weatherVM.weatherModel.value!
            weatherView.update(with: weather)
        }
        return cell
    }
}



// MARK: - User's Current Location Handling
extension WeatherViewController: CLLocationManagerDelegate{
    
    /// handle Location after received from Location Manager
    /// - Parameter location: Location
    func performLocationUpdate(location: CLLocation?){
        if let location = location{
            User.Location.shared.latitude = location.coordinate.latitude
            User.Location.shared.longitude = location.coordinate.longitude
            self.getWeatherForAvailableLocation(location: User.Location.shared)
        }
    }
    
    func requestLocationAccess(){
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        else{
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            // Request the appropriate authorization based on the needs of the app
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Sorry, restricted")
            // Optional: Offer to take user to app's settings screen
        case .denied:
            print("Sorry, denied")
            // Optional: Offer to take user to app's settings screen
        case .authorizedAlways, .authorizedWhenInUse:
            // The app has permission so start getting location updates
            manager.startUpdatingLocation()
        @unknown default:
            print("Unknown status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Some location updates can be invalid or have insufficient accuracy.
        // Find the first location that has sufficient horizontal accuracy.
        // If the manager's desiredAccuracy is one of kCLLocationAccuracyNearestTenMeters,
        // kCLLocationAccuracyHundredMeters, kCLLocationAccuracyKilometer, or kCLLocationAccuracyThreeKilometers
        // then you can use $0.horizontalAccuracy <= manager.desiredAccuracy. Otherwise enter the number of meters desired.
        if let location = locations.first(where: { $0.horizontalAccuracy <= 50 }) {
            print("location found: \(location)")
            self.performLocationUpdate(location: locationManager.location)
            // stop updating Location if you don't need any more updates
            manager.stopUpdatingLocation()
        }else{
            showAlert(message: AppMessages.noLocationFound)
        }
    }
    
    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Show Alert that Not able to fetch User's Location
        showAlert(message: error.localizedDescription)
    }
}



// MARK: - User's Location Choice Handling
extension WeatherViewController: LocationInputProtocol{
    
    
    /// Request User's Location
    func userSelectedMyLocation() {
        requestLocationAccess()
    }
    
    /// Open City List
    func openCityList() {
        let cityPickerVC = self.storyboard!.instantiateViewController(withIdentifier: "CityListViewController") as! CityListViewController
        cityPickerVC.delegate = self
        self.pushVC(destinationVC: cityPickerVC)
    }
    
    /// User's Search for location
    /// - Parameter location: location search key
    func userSearchedLocation(location: String) {
        locationManager.stopUpdatingLocation()
        if !location.trimmingCharacters(in: .whitespaces).isEmpty {
            getWeatherForSearchLocation(location: location)
        }else{
            self.showAlert(message: AppMessages.selectLocation)
        }
    }
}

// MARK: - City List's City Selection Handler
extension WeatherViewController: CityListProtocol{
    
    /// City Selected, Pass city id to handler
    /// - Parameter cityId: City Id
    func didSelectedCity(cityId: String) {
        getWeatherForSelectedCity(cityId: cityId)
    }
}



// MARK: - Web Service Calling
extension WeatherViewController {
    
    /// Get Weather information for User's Location as in Lat & Lon
    /// - Parameter location: user's location
    func getWeatherForAvailableLocation(location: User.Location){
        print("Lat:\(location.latitude!)")
        print("Lat:\(location.longitude!)")
        let lat = String(location.latitude)
        let lon = String(location.longitude)
        let params : [String : String] = ["lat" : lat , "lon" : lon, "units" : User.shared.tempratureUnit.rawValue, "appid" : NetworkHelperConstants.weatherAPIKey]
        fetchWeather(params: params)
    }
    
    /// Get Weather information for user's selected city
    /// - Parameter cityId: id of the city
    func getWeatherForSelectedCity(cityId: String){
        let params : [String : String] = ["id" : cityId , "units" : User.shared.tempratureUnit.rawValue, "appid" : NetworkHelperConstants.weatherAPIKey]
        fetchWeather(params: params)
    }
    
    /// Get weather information for user's Searched Location
    /// - Parameter location: user's search key
    func getWeatherForSearchLocation(location: String){
        let params : [String : String] = ["q" : location , "units" : User.shared.tempratureUnit.rawValue,"appid" : NetworkHelperConstants.weatherAPIKey]
        fetchWeather(params: params)
    }
    
    
    /// Actually Fetches the Weather
    /// - Parameter params: Parameters for fetching weather information
    func fetchWeather(params: [String:String]){
        
        if Reachability.shared.status == .connectedViaWiFi || Reachability.shared.status == .connectedViaCellular {
        self.tblWeather.isHidden = false
        self.tblWeather.showLoading(activityColor: .link)
        weatherVM.fetchWeather(params: params) { result in
            self.tblWeather.hideLoading()
            switch result {
            case .success(_):
                let _ = HistoryProvider.writeWeatherHistory(weather: self.weatherVM.weatherModel.value)
//                print("History Saved:\(saved ? "Yes" : "No")")
                //No need to handle UI Updates here as whenever a new weather will be updated and the binding will take place and trigger UI Update
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            }
        }
        }else{
            self.showAlert(message: Error.network.localizedDescription)
        }
    }
}
