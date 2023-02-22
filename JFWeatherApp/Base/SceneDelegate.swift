//
//  SceneDelegate.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/20/23.
//

import Foundation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var mainCoordinator: MainCoordinator?
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
        let storyboard = UIStoryboard(name: String(describing: WeatherView.self), bundle: nil)
        let navigationViewController = UINavigationController()
        mainCoordinator = MainCoordinator(presenter: navigationViewController)
        mainCoordinator?.start()
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}
