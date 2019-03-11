//
//  AppDelegate.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 2/27/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Sign in google error: \(error)")
        } else {
            print("User id = \(user.userID)")
            print("Full name = \(user.profile.name)")
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("ERRRRRRRRRRRRRR")
    }


    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance()?.clientID = "395629890132-r9av56fvfekqjvta9osdlb6q7580vc5q.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        Messaging.messaging().delegate = self
        configApplePush(application)

        // handle tap notification when app was closed
        if let _ = launchOptions?[.remoteNotification] {
            // tap to notification while app closed
//            fatalError("tap to notification while app closed")
        }
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // tap to notification while app is in running state
        if UIApplication.shared.applicationState == .background {
//            fatalError("tap to notification while app waked from background")
        } else {
//            fatalError("tap to notification while app is in running state")
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, options: options)
        let handledGoogle = GIDSignIn.sharedInstance()?.handle(url,
                                                               sourceApplication: options[.sourceApplication] as? String,
                                                               annotation: options[.annotation])
        return handled ?? true && handledGoogle ?? true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge])
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("remote instance ID token: \(result.token)")
            }
        }
    }

    func configApplePush(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, _) in
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }

}

