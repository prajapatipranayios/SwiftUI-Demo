//
//  SceneDelegate.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 20/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
//        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {

            let window = UIWindow(windowScene: windowScene)

            if (UserDefaults.standard.value(forKey: UserDefaultType.accessToken) != nil) {

//                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let objVC = storyBoard.instantiateViewController(withIdentifier: "FFTabVC") as! FFTabVC
//                let homeNavVC = UINavigationController(rootViewController: objVC)
//                homeNavVC.interactivePopGestureRecognizer?.isEnabled = false
//                homeNavVC.navigationBar.isHidden = true
//
//                window.rootViewController = homeNavVC
//
//                self.window = window
//                window.makeKeyAndVisible()
            }
        }
        
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let openURLContext = URLContexts.first
        if (openURLContext != nil) {
            ApplicationDelegate.shared.application(UIApplication.shared, open: openURLContext!.url, sourceApplication: openURLContext?.options.sourceApplication, annotation: openURLContext?.options.annotation)
        }
    }
}

