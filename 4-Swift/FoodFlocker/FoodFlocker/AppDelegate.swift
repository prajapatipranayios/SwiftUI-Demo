//
//  AppDelegate.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 20/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import IQKeyboardManagerSwift
import GoogleMaps
import Fabric
import UserNotifications
import Firebase
import Crashlytics

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reach: Reachability?
    var currentlocation: CLLocationCoordinate2D?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        UITextViewWorkaround.unique.executeWorkaround()

        Utilities.setUserDefaultValue()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true
        
        GMSServices.provideAPIKey(AppInfo.GOOGLE_MAP_API_KEY.returnAppInfo())

        //Facebook SignIn
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
        for family in UIFont.familyNames {
            print("\(family)")

            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }

        // For get device token & notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()

        // Use Firebase library to configure APIs
//        FirebaseApp.configure()
//        Messaging.messaging().delegate = self
        
        
        // Allocate a reachability object
        reach = Reachability.forInternetConnection()
        reach!.reachableOnWWAN = false
        
        // Here we set up a NSNotification observer. The Reachability that caused the notification is passed in the object parameter
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged),
            name: NSNotification.Name.reachabilityChanged,
            object: nil
        )
        reach!.startNotifier()

//        if (UserDefaults.standard.value(forKey: UserDefaultType.accessToken) != nil) && !isSetRootController {
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            let objVC = storyBoard.instantiateViewController(withIdentifier: "FFTabVC") as! FFTabVC
//            let objNavVC = UINavigationController(rootViewController: objVC)
//            objNavVC.interactivePopGestureRecognizer?.isEnabled = false
//            objNavVC.navigationBar.isHidden = true
//            UIApplication.shared.windows.first?.rootViewController = objNavVC
//            UIApplication.shared.windows.first?.makeKeyAndVisible()
//        }
        
        return true
    }

     func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
         if notificationSettings.types != UIUserNotificationType() {
             UIApplication.shared.registerForRemoteNotifications()
         }
     }
     
     func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
         let token = tokenParts.joined()
         print("Device Token: \(token)")
     }
     
     
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         debugPrint("Received: \(userInfo)")
         completionHandler(.newData)
     }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // Change Reachability ON and OFF
    @objc func reachabilityChanged(notification: NSNotification) {
        if reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() {
            
        }
    }
    
    // Check Reachability
    func checkInternetConnection() -> Bool {
        if reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() {
            return true
        }else {
            return false
        }
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.
        let userInfo = notification.request.content.userInfo
        let temp = ["title":notification.request.content.title,"body":notification.request.content.body]
        
        
        
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let temp = ["title":response.notification.request.content.title,"body":response.notification.request.content.body]
        
        print(userInfo)
        print(temp)
        
        if (userInfo["gcm.notification.module"] != nil) {
            if (UserDefaults.standard.value(forKey: UserDefaultType.accessToken) != nil) {
                if let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController
                {
                    if (userInfo["gcm.notification.module"] as! String) == "OtherUserDetail" {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let objVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        objVC.userId = Int(userInfo["gcm.notification.moduleId"] as! String) ?? 0
                        navigationController.pushViewController(objVC, animated: true)
                    }
                    
                    if (userInfo["gcm.notification.module"] as! String) == "Post" {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
                        let objVC = storyBoard.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
                        objVC.postId = Int(userInfo["gcm.notification.moduleId"] as! String) ?? 0
                        navigationController.pushViewController(objVC, animated: true)
                    }
                    
                    if (userInfo["gcm.notification.module"] as! String) == "Event" {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
                        let objVC = storyBoard.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
                        objVC.eventId = Int(userInfo["gcm.notification.moduleId"] as! String) ?? 0
                        navigationController.pushViewController(objVC, animated: true)
                    }
                    
                }
                else
                {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let objVC = storyBoard.instantiateViewController(withIdentifier: "LaunchScreenVC") as! LaunchScreenVC
                    objVC.module = userInfo["gcm.notification.module"] as! String
                    objVC.moduleId = Int(userInfo["gcm.notification.moduleId"] as! String) ?? 0
                    let objNavVC = UINavigationController(rootViewController: objVC)
                    objNavVC.interactivePopGestureRecognizer?.isEnabled = false
                    objNavVC.navigationBar.isHidden = true
                    UIApplication.shared.windows.first?.rootViewController = objNavVC
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            }
        }
    }
    
}


extension AppDelegate : MessagingDelegate {
    
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("remoteMessage.appData: \(remoteMessage.appData)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcmToken: \(fcmToken)")
        UserDefaults.standard.set("\(fcmToken)", forKey: UserDefaultType.fcmToken)
    }
}
