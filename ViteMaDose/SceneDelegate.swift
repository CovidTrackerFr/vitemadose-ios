//
//  SceneDelegate.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let homeController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeController)
        window.rootViewController = navigationController
        self.window = window

        window.makeKeyAndVisible()
    }

}
