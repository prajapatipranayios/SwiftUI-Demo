//
//  AppDelegate.swift
//  Tussly
//
//  Created by Auxano on 11/07/25.
//

import UIKit
import IQKeyboardManagerSwift
import Reachability
import GoogleSignIn
import CometChatSDK
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import PostHog


let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var reachability: Reachability?
    var isAutoLogin: Bool = false
    var tusslyTabVC: (()->TusslyTabVC)?
    var intUsersUnreadCount: Int = 0
    var intGroupsUnreadCount: Int = 0
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UITextViewWorkaround.unique.executeWorkaround()
        IQKeyboardManager.shared.isEnabled = true
        
        FirebaseApp.configure()
        setupPushNotifications(application)
        
        do {
            reachability = try Reachability()
            try reachability!.start()
        } catch {
            print("Unable to start notifier")
        }
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            
        }
        
        let appSettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: CometAppConstants.REGION).autoEstablishSocketConnection(true).build()
        CometChat.init(appId: CometAppConstants.APP_ID, appSettings: appSettings) { isSuccess in
            print("CometChat Initialized Successfully: \(isSuccess)")
            
        } onError: { error in
            print("CometChat Initialization Failed with Error: \(error.errorDescription)")
        }
        
        if (UserDefaults.standard.value(forKey: UserDefaultType.accessToken) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.accessToken)! is String {
            isAutoLogin = true
        }
        
        let POSTHOG_API_KEY = "phc_VOtS7XS9Zkn25tqzswLcbyn242DOfWOI62uupStqVGo"
        let POSTHOG_HOST = "https://us.i.posthog.com"
        
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        config.sessionReplay = true
        config.captureScreenViews = true
        config.sessionReplayConfig.screenshotMode = true
        config.sessionReplayConfig.captureLogs = true
        config.sessionReplayConfig.maskAllImages = false
        config.sessionReplayConfig.maskAllTextInputs = false
        config.sessionReplayConfig.throttleDelay = 1.0
        
        PostHogSDK.shared.setup(config)
        
        PostHogSDK.shared.capture("iOS-Tussly-Event")
        PostHogSDK.shared.screen("AppDelegate", properties: [:])
        
        return true
    }
    
    func setupPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("Permission granted: \(granted)")
        }
        
        application.registerForRemoteNotifications()
        self.setupNotificationCategories()
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self // Set the delegate
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Already authorized")
                self.setupNotificationCategories() // Set up categories if already authorized
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .denied:
                print("Denied")
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    
                    guard granted else { return }
                    self.setupNotificationCategories()
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            default:
                break
            }
        }
    }
    
    func setupNotificationCategories() {
        //let accept = UNNotificationAction(identifier: "Accept", title: "Accept", options: [.foreground])
        //let decline = UNNotificationAction(identifier: "Decline", title: "Decline", options: [.foreground])
        
        let acceptAction = UNNotificationAction(identifier: "Accept", title: "Accept", options: [.foreground])
        let declineAction = UNNotificationAction(identifier: "Decline", title: "Decline", options: [.foreground])
        //let declineAction = UNNotificationAction(identifier: "Decline", title: "Decline", options: [.destructive]) // Example of destructive
        
        //let newsCategory = UNNotificationCategory(identifier: "button", actions: [accept,decline], intentIdentifiers: [], options: [])
        
        let newsCategory = UNNotificationCategory(identifier: "button", actions: [acceptAction, declineAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
        
        print("Already authorized 1")
    }
    
    
    func acceptRejectNotification(notificationId: Int,actionType: String) {
        if !Network.reachability.isReachable {
            return
        }
        APIManager.sharedManager.postData(url: APIManager.sharedManager.NOTIFICATION_ACTION, parameters: ["notificationId":notificationId, "actionType":actionType]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                if let link = URL(string: (response?.result?.redirectUrl)!) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(link)
                    } else {
                        UIApplication.shared.openURL(link)
                    }
                }
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    var myOrientation: UIInterfaceOrientationMask = .portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        CometChat.configureServices(.willResignActive)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CometChat.configureServices(.didEnterBackground)
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        let authToken = ""
  
    }
}

extension AppDelegate : MessagingDelegate {
        
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcmToken: \(fcmToken!)")
        UserDefaults.standard.set("\(fcmToken!)", forKey: UserDefaultType.fcmToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("print notification details in background... - 1")    //  By Pranay
        
        var isLoadNotification: Bool = true
        
        if let notificationData = notification.request.content.userInfo as NSDictionary? as? [String: Any] {
            if notificationData["tags"] != nil {
                if let data = notificationData["tags"]! as? String {

                    let rawData = Data(data.utf8)
                    var dict : [String : Any]? = [:]
                    do {
                        dict = try JSONSerialization.jsonObject(with: rawData, options: []) as? [String: Any]
                        print(dict!["notificationId"]!)
                    } catch {
                        print("Error: \(error)")
                    }
                    guard let responseData = try? JSONSerialization.data(withJSONObject: dict as Any, options: []) else { return }
                    let notificationPayload : NotificationPayload = try! JSONDecoder().decode(NotificationPayload.self, from: responseData)
                    
                    if ["schedule_removed", "forfeit_match"].contains(notificationPayload.action ?? "") {
                        //APIManager.sharedManager.isNextMatch = true
                        APIManager.sharedManager.strNotificationAction = notificationPayload.action ?? ""
                        NotificationCenter.default.post(name: .tournamentNotificationObserver, object: nil)
                    }
                }
                
                if (UserDefaults.standard.value(forKey: UserDefaultType.notificationCount) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.notificationCount)! is Int {
                    var notificationCount : Int = 0
                    notificationCount = UserDefaults.standard.value(forKey: UserDefaultType.notificationCount) as! Int
                    notificationCount += 1
                    UserDefaults.standard.set(notificationCount, forKey: UserDefaultType.notificationCount)
                }

                tusslyTabVC!().notificationCount()
                //completionHandler([.alert, .badge, .sound])
            }
            else if notificationData["conversationId"] != nil {
                if let data = try? JSONSerialization.data(withJSONObject: notificationData, options: []) {
                    let notificationPayload = try? JSONDecoder().decode(ChatNotificationPayload.self, from: data)

                    if (notificationPayload?.conversationID ?? "" != "") {
                        print("Conversation Id from notification >>>>>>>>>>>>>>", notificationPayload?.conversationID ?? "")
                        self.getChatUnreadCount()
                        
                        if APIManager.sharedManager.chatActiveConversationId == (notificationPayload?.conversationID ?? "") {
                            isLoadNotification = false
                        }
                    }
                }
            }
        }
        
        if isLoadNotification {
            completionHandler([.banner, .badge, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notificationData = response.notification.request.content.userInfo as NSDictionary? as? [String: Any] {
            //if notificationData["gcm.notification.tags"] != nil {
            print("Notification DATA --> ")
            print(notificationData)
            if notificationData["tags"] != nil {
                if let data = notificationData["tags"]! as? String {
                    let rawData = Data(data.utf8)
                    var dict : [String : Any]? = [:]
                    do {
                        dict = try JSONSerialization.jsonObject(with: rawData, options: []) as? [String: Any]
                        print(dict!["notificationId"]!)
                    } catch {
                        print("Error: \(error)")
                    }
                       
                    if response.actionIdentifier == "Accept" {
                        print("Tap Accept - \(dict!["notificationId"]! as! Int)")
                        self.acceptRejectNotification(notificationId: dict!["notificationId"]! as! Int, actionType: "POSITIVE")
                        //print("Tap Accept")
                    } else if response.actionIdentifier == "Decline" {
                        print("Tap Decline - \(dict!["notificationId"]! as! Int)")
                        self.acceptRejectNotification(notificationId: dict!["notificationId"]! as! Int, actionType: "NEGATIVE")
                    }
                    
                    guard let responseData = try? JSONSerialization.data(withJSONObject: dict as Any, options: []) else { return }
                    let notificationPayload : NotificationPayload = try! JSONDecoder().decode(NotificationPayload.self, from: responseData)
                    
                    APIManager.sharedManager.isNextMatch = false
                    /*if (notificationPayload.action ?? "" == "upcoming_match") || (notificationPayload.action ?? "" == "check_in") || (notificationPayload.action ?? "" == "schedule_removed") {
                        
                    }   //  */
                    if ["upcoming_match", "check_in", "schedule_removed"].contains(notificationPayload.action ?? "") {
                        APIManager.sharedManager.isNextMatch = true
                    }
                    
                    if APIManager.sharedManager.user == nil {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if  let rootVC = storyboard.instantiateViewController(withIdentifier: "TusslyTabVC") as? TusslyTabVC {
                            let navVC = UINavigationController(rootViewController: rootVC)
                            // set the view controller as root
                            self.window?.rootViewController = navVC
                            self.window?.addSubview(navVC.view)
                            self.window?.makeKeyAndVisible()
                            if !APIManager.sharedManager.isNotificationClick {
                                APIManager.sharedManager.isNotificationClick = true
                                if (notificationPayload.action ?? "" == "upcoming_match") {
                                    APIManager.sharedManager.isArenaTabOpen = true
                                }
                                else if (notificationPayload.action ?? "" == "report_generated") {
                                    APIManager.sharedManager.isPlayerCardOpen = true
                                    APIManager.sharedManager.isPlayerReportsTabOpen = true
                                }
                                if APIManager.sharedManager.isNextMatch {
                                    APIManager.sharedManager.tournamentDetail = notificationPayload.leagues![0]
                                }
                            }
                        }
                    }
                    else {
                        if APIManager.sharedManager.isNextMatch {
                            APIManager.sharedManager.isNextMatch = false
                            self.tusslyTabVC!().isFromSerchPlayerTournament = true
                            self.tusslyTabVC!().tournamentDetail = notificationPayload.leagues![0]
                            self.tusslyTabVC!().isLeagueJoinStatus = true
                            //APIManager.sharedManager.isArenaTabOpen = true
                            if (notificationPayload.action ?? "" == "upcoming_match") {
                                APIManager.sharedManager.isArenaTabOpen = true
                            }
                            self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[5])
                        }
                        else if (notificationPayload.action ?? "" == "report_generated") {
                            APIManager.sharedManager.isPlayerCardOpen = true
                            APIManager.sharedManager.isPlayerReportsTabOpen = true
                            self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[8])
                        }
                        else {
                            self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[3])
                        }
                    }
                }
            }
            else if notificationData["conversationId"] != nil {
                
                if let data = try? JSONSerialization.data(withJSONObject: notificationData, options: []) {
                    
                    var notificationPayload: ChatNotificationPayload?
                    do {
                        let payload = try JSONDecoder().decode(ChatNotificationPayload.self, from: data)
                        notificationPayload = payload
                        APIManager.sharedManager.chatNotificationPayload = payload
                        print(payload.conversationID ?? "")
                    } catch {
                        print("Decode error: \(error.localizedDescription)")
                    }
                    
                    if (notificationPayload?.conversationID ?? "" != "") {
                        if APIManager.sharedManager.user == nil {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if  let rootVC = storyboard.instantiateViewController(withIdentifier: "TusslyTabVC") as? TusslyTabVC {
                                let navVC = UINavigationController(rootViewController: rootVC)
                                // set the view controller as root
                                self.window?.rootViewController = navVC
                                self.window?.addSubview(navVC.view)
                                self.window?.makeKeyAndVisible()
                                if !APIManager.sharedManager.isNotificationClick {
                                    APIManager.sharedManager.isNotificationClick = true
                                    APIManager.sharedManager.isForChatNotification = true
                                }
                            }
                        }
                        else {
                            //self.tusslyTabVC!().selectedIndex = 0
                            //APIManager.sharedManager.isForChatNotification = true
                            self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[2])
                        }
                    }
                }
            }
        }
        do {
            completionHandler()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Received notification :: \(userInfo.description)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // By Pranay
        switch UIApplication.shared.applicationState {
        case .background :
            if (UserDefaults.standard.value(forKey: UserDefaultType.notificationCount) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.notificationCount)! is Int {
                var notificationCount : Int = 0
                notificationCount = UserDefaults.standard.value(forKey: UserDefaultType.notificationCount) as! Int
                notificationCount += 1
                UserDefaults.standard.set(notificationCount, forKey: UserDefaultType.notificationCount)
            }
            tusslyTabVC!().notificationCount()
            break
        case .active:
            break
        case .inactive:
            break
        @unknown default:
            break
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Register for remote notifications")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate {
    func getChatUnreadCount() {
        CometChat.getUnreadMessageCountForAllUsers { dictUnreadCount in
            if let tempUreadCount = dictUnreadCount as? [String: Int] {
                self.intUsersUnreadCount = tempUreadCount.keys.count
                
                self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
                
            }
        } onError: { error in
            print("\(error?.errorCode ?? "")")
        }
        
        CometChat.getUnreadMessageCountForAllGroups { dictUnreadCount /*<#[String : Any]#>*/ in
            if let tempUreadCount = dictUnreadCount as? [String: Int] {
                self.intGroupsUnreadCount = tempUreadCount.keys.count
                
                self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
            }
        } onError: { error in
            print("\(error?.errorCode ?? "")")
        }
    }
}
