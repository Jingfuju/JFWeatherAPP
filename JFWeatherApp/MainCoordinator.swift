//
//  MainCoordinator.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/21/23.
//

import Foundation
import UIKit


protocol Coordinator {
    var presenter: UIViewController? { get set }
    
    func start()
    func stop()
}

extension Coordinator {
    var presenter: UIViewController? {
        get { return nil }
        set {}
    }
    func stop() {}
}


protocol MainCoordinatorDelegate {
    
}

final class MainCoordinator: Coordinator {
    
    weak var presenter: UIViewController?
    
    
    init(
        presenter: UIViewController?
    ) {
        self.presenter = presenter
    }
    
    func start() {
        guard let presenter = presenter as? UINavigationController else {
            assertionFailure("the presenter should be root navigation controller")
            return
        }
        presenter.navigationBar.tintColor = .gray
        presenter.modalPresentationStyle = .overFullScreen
        
        let storyboard = UIStoryboard(
            name: String(describing: WeatherView.self),
            bundle: nil
        )
        let weatherViewController = storyboard.instantiateViewController(
            withIdentifier: String(describing: WeatherViewController.self)
        ) as! WeatherViewController
        presenter.pushViewController(weatherViewController, animated: true)
    }
}
