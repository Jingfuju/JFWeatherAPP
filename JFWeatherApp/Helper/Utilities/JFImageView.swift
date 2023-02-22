//
//  JFImageView.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/22/23.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class JFImageView: UIImageView {
    var imageURL: URL?

    let activityIndicator = UIActivityIndicatorView()

    /// Download an image from URL with caching
    /// - Parameter url: url of the image to be downloaded
    func loadImageWithURL(_ url: URL) {
        activityIndicator.color = .darkGray
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageURL = url
        image = nil
        activityIndicator.startAnimating()

        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            image = imageFromCache
            activityIndicator.stopAnimating()
            return
        }

        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            if error != nil {
                print(error as Any)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }

            DispatchQueue.main.async {
                if let unwrappedData = data, let imageToCache = UIImage(data: unwrappedData) {
                    if self.imageURL == url {
                        self.image = imageToCache
                    }
                    imageCache.setObject(imageToCache, forKey: url as AnyObject)
                }
                self.activityIndicator.stopAnimating()
            }
        }).resume()
    }
}
