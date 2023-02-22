//
//  HistoryProvider.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/21/23.
//

import Foundation


class HistoryProvider {


    /// Save Weather History in User default
    /// - Parameter weather: Weather to be saved
    /// - Returns: boolean indicating the success or failure
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
            
            if weatherList.count == Constants.MaxHistoryCount {
                weatherList.insert(weather, at: 0)
                weatherList.removeLast()
            } else {
                weatherList.insert(weather, at: 0)
            }
        }
        
        do {
            let encodedData = try JSONEncoder().encode(weatherList)
            userDefaults.set(encodedData, forKey: AppKeys.WeatherList)
            userDefaults.synchronize()
            return true
        } catch {
            return false
        }
    }

    /// Read Weather History from User defaults
    /// - Returns:  array of Weather [Weather]?
    class func readWeatherHistory() -> [Weather]? {
        var weatherList: [Weather]
        guard
            let savedData = UserDefaults.standard.object(forKey: AppKeys.WeatherList) as? Data
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

    /// Clear Weather History
    /// - Returns: if able to clear history or not
    class func clearWeatherHistory() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: AppKeys.WeatherList)
    }
}


class LastedRecentUsedLocationCacheProvider {
    
    class Node {
        var key: Int
        var value: Int
        var prev: Node?
        var next: Node?
        init(_ key: Int, _ value: Int) {
            self.key = key
            self.value = value
        }
    }
    
    var head: Node
    var tail: Node
    var size: Int
    var capacity: Int
    var dummy = Node(0, 0)
    var cache = [Int: Node]()

    init(_ capacity: Int) {
        self.capacity = capacity
        self.size = 0
        self.cache.reserveCapacity(capacity)
        head = dummy
        tail = dummy
    }
    
    fileprivate func remove(_ node: Node) {
        
        if size == 0 { return }
        if size == 1 {
            head = dummy
            tail = dummy
        } else {
            if node === head {
                
                let next = head.next!
                dummy.next = next
                next.prev = dummy
                head = next
            } else if node === tail {
                
                let prev = node.prev!
                prev.next = nil
                tail = prev
            } else {
            
                let next = node.next!
                let prev = node.prev!
                prev.next = next
                next.prev = prev
            }
        }
        
        cache.removeValue(forKey: node.key)
        size -= 1
    }
    
    fileprivate func add(_ node: Node) {
        
        if size == 0 {
            dummy.next = node
            node.prev = dummy
            head = node
            tail = node
        } else {
            dummy.next = node
            node.prev = dummy
            node.next = head
            head.prev = node
            head = node
        }
        cache[node.key] = node
        size += 1
    }
    
    func get(_ key: Int) -> Int {
        
        guard size > 0 else { return -1 }
        guard let node = cache[key] else{ return -1 }
        defer {
            remove(node)
            add(node)
        }
        
        return node.value
    }
    
    func put(_ key: Int, _ value: Int) {
        guard capacity > 0 else { return }
        let node = cache[key]
        if node == nil {
            add(Node(key, value))
            
            if size > capacity {
                remove(tail)
            }
        } else {
            node!.value = value
            remove(node!)
            add(node!)
        }
    }
}
