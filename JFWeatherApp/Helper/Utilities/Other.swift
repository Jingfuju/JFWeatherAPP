//
//  File1.swift
//  AUWeatherApp
//
//  Created by Anand Upadhyay on 09/02/23.
//

import Foundation
import UIKit


extension Int {
    /// Date from the Timestamp
    /// - Returns: Date from Timestamp
    func fromUnixTimeStamp() -> Date? {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return date
    }
}

extension Date {
    /// Convert Date to String readable
    /// - Parameter format: format to be used default is Short
    /// - Returns: String representation of the date
    func convertToString(format: String = Constants.DateFormat_Short) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let formatedStringDate = dateFormatter.string(from: self)
        return formatedStringDate
    }
}


enum AppUtility {
    // MARK: - Public API

    //    static var baseUrl: URL {
    //        URL(string: string(for: "WEATHER_API_BASE_URL"))!
    //    }

    /// Retrive value of a Key from Info dictionary
    /// - Parameter key: name of the key
    /// - Returns: value of key from info plist
    static func infoForKey(for key: String) -> String {
        Bundle.main.infoDictionary?[key] as! String
    }
}
