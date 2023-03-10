//
//  UIView+Loading.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/22/23.
//

import Foundation
import UIKit

extension UIView {
    /// Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval
    /// - Parameter duration: animation duration
    func zoomIn(duration: TimeInterval = 0.2, completion: ((Bool) -> Void)? = nil) {
        transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () in
            self.transform = .identity
        }) { animationCompleted in
            completion?(animationCompleted)
        }
    }

    /**
     
     Add A loading Indicator in View.
     
     - Parameters:
        - activityColor: color of the activity indicator.
        - interactionEnabled: interaction on / off default is false.
        - backgroundColor:  backgournd color of the loading indicator default is UIColor.systemGroupedBackground
     
     */
     
    func showLoading(activityColor: UIColor, interactionEnabled: Bool = false, backgroundColor: UIColor = .systemGroupedBackground) {
        let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = Constants.loadingIndicatorTag
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: backgroundView.frame.size.width, height: backgroundView.frame.size.height))
        activityIndicator.center = CGPoint(x: backgroundView.frame.size.width / 2, y: backgroundView.frame.size.height / 2)
        backgroundView.center = center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        isUserInteractionEnabled = interactionEnabled
        backgroundView.addSubview(activityIndicator)
        addSubview(backgroundView)
    }

    /// Hide Loading Indicator
    func hideLoading() {
        if let background = viewWithTag(Constants.loadingIndicatorTag) {
            background.removeFromSuperview()
        }
        isUserInteractionEnabled = true
    }
}

extension UIView {
    @discardableResult
    class func fromNib<T: UIView>() -> T {
        let name = String(describing: Self.self)
        guard let nib = Bundle(for: Self.self).loadNibNamed(
            name, owner: nil, options: nil
        )
        else {
            fatalError("Missing nib-file named: \(name)")
        }
        return nib.first as! T
    }
}

