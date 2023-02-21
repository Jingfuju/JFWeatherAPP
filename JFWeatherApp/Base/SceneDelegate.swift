//
//  SceneDelegate.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/20/23.
//

import Foundation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: String(describing: WeatherView.self), bundle: nil)
        window.rootViewController = storyboard.instantiateViewController(
            withIdentifier: String(describing: WeatherViewController.self)
        ) as! WeatherViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}
