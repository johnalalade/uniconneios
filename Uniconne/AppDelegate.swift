//
//  AppDelegate.swift
//  Uniconne
//
//  Created by uniconne on 09/08/2021.
//

import UIKit
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

let gcmMessageIDKey = "Uniconne.com"
var fcmTokenn = "ja"
var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //let nextViewController = self.window?.rootViewController as? ViewController
       //nextViewController?.token = "jaa"
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token init: \(token)")
            self.fcmTokenn = token
           // let nextViewController = self.window?.rootViewController as? ViewController
           // nextViewController?.token = token
            //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
          }
                        
        }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        print("Hello worldy")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    //Messaging
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //Messaging.messaging().token { token, error in
         // if let error = error {
           // print("Error fetching FCM registration token: \(error)")
        // } else if let token = token {
         //   print("FCM registration token: \(token)")
         //   NSLog("InstanceID token: %@", token);
         //   let nextViewController = self.window?.rootViewController as? ViewController
          //  nextViewController?.token = token
            //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
         // }
        //}
        print("Hello world Hey")
        print("Firebase registration token rec: \(String(describing: fcmToken))")
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
        
        self.fcmTokenn = fcmToken ?? ""
        //let nextViewController = self.window?.rootViewController as? ViewController
        //nextViewController?.token = fcmToken
        // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) -> String {
        print("Hello world1")
        Messaging.messaging().apnsToken = deviceToken
        print(deviceToken.map({String(format: "%20x", $0)}).joined())
        self.fcmTokenn = deviceToken.map({String(format: "%20x", $0)}).joined()
        //let nextViewController = self.window?.rootViewController as? ViewController
       //nextViewController?.token = deviceToken.map({String(format: "%20x", $0)}).joined()
        return deviceToken.map({String(format: "%20x", $0)}).joined()
        //Messaging.messaging().token { (token, error) in
              //  if let error = error {
                 //   print("Error fetching remote instance ID: \(error.localizedDescription)")
               // } else if let token = token {
                    //print("Token is \(token)")
                   // let nextViewController = self.window?.rootViewController as? ViewController
                  // nextViewController?.token = token
                    
               // }
            //}
        //let token = Messaging.messaging().fcmToken
       // let nextViewController = self.window?.rootViewController as? ViewController
      //  nextViewController?.token = token
    }
    
      // Receive displayed notifications for iOS 10 devices.
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                    -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // ...

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([[.banner, .list, .sound]])
      }

      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // ...

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)

        completionHandler()
      }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let _ = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        print(deviceToken.map({String(format: "%20x", $0)}).joined())
        self.fcmTokenn = deviceToken.map({String(format: "%20x", $0)}).joined()
        //let nextViewController = self.window?.rootViewController as? ViewController
       //nextViewController?.token = deviceToken.map({String(format: "%20x", $0)}).joined()
    }
}

