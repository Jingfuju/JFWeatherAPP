//
//  HistoryProvider.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/21/23.
//

import Foundation


/**
Provide the read, write and removeAll functionality for search city history list.
 
 - Leverage the LRU (least recently used) data structure to handle the history list with at most 5 item.
 - Used the NSUserDefault as the storage mechanism.
 
 */

class HistoryProvider {
    
    /**
     
     Class method to save Weather History in the User default and at most 5 items are suppported.
     The newly added item is always append to the head of the list. If we have more than 5 history, the last one will be removed from the storage.
     
      - Parameter weather: the Weather data model to be saved.
      - Returns: boolean value indicating the success or failure of data persisient aciton.
     
     */
    
    @discardableResult
    class func writeWeatherHistory(weather: Weather) -> Bool {
        var weatherList: [Weather]
        var weatherHistoryList: [Weather]?
        
        let userDefaults = UserDefaults.standard
        weatherHistoryList = HistoryProvider.readWeatherHistory()
        if weatherHistoryList?.count ?? 0 == 0 {
            weatherList = [weather]
        } else {
            guard let weatherHistoryList = weatherHistoryList else { return false }
            weatherList = weatherHistoryList
            for i in weatherList.indices {
                if weather.name! == weatherList[i].name! {
                    weatherList.remove(at: i)
                    break
                }
            }
            
            if weatherList.count == Constants.maxHistoryCount {
                weatherList.insert(weather, at: 0)
                weatherList.removeLast()
            } else {
                weatherList.insert(weather, at: 0)
            }
        }
        
        do {
            let encodedData = try JSONEncoder().encode(weatherList)
            userDefaults.set(encodedData, forKey: AppKeys.weatherList)
            userDefaults.synchronize()
            return true
        } catch {
            return false
        }
    }
    
    
    /**
     
    Class method to Retrived the Weather History from saved User defaults
     
     - Returns: the Weather data model array. It will be nil, if we do not have the weather history or retrieving action failure.
     
     */

    class func readWeatherHistory() -> [Weather]? {
        var weatherList: [Weather]
        guard
            let savedData = UserDefaults.standard.object(forKey: AppKeys.weatherList) as? Data
        else {
            return nil
        }
        do {
            weatherList = try JSONDecoder().decode([Weather].self, from: savedData)
            return weatherList
        } catch {
            return nil
        }
    }

    /**
        
     Class method to clear the weather search history from data persistent.
     
     */
    class func clearWeatherHistory() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: AppKeys.weatherList)
    }
}
