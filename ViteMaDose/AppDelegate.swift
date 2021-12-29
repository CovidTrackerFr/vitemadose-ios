// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit
import Firebase
import SafariServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        #if DEBUG
        resetUserDefaultsIfNeeded()
        #endif
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Register for remote notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let stringToken = deviceToken.map { data in String(format: "%02.2hhx", data) }.joined()
        Log.i("APP APNS TOKEN: \(stringToken)")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Log.e("ERROR REGISTERING FOR NOTIFICATIONS \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenter Delegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            // Fallback on earlier versions
            completionHandler([.alert, .sound])
        }
        // Analytics
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Analytics
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // If push contains an URL, open it in a SFSafariViewController
        guard
            let urlString = userInfo["url"] as? String,
            let url = URL(string: urlString),
            url.isValid
        else {
            completionHandler()
            return
        }

        open(url: url, completion: completionHandler)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    private func open(url: URL, completion: @escaping () -> Void) {
        let window = UIApplication.shared.windows.filter(\.isKeyWindow)
        guard let rootViewController = window.first?.rootViewController else {
            return
        }

        let config = SFSafariViewController.Configuration()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.modalPresentationStyle = .pageSheet

        DispatchQueue.main.async {
            rootViewController.present(safariViewController, animated: true, completion: completion)
        }
    }
}

// MARK: - Messaging Delegate

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        // Let FCM know about the new token
        let dataDict: [String: String] = ["token": fcmToken.emptyIfNil]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )

        Log.i("RECEIVED FCM TOKEN: \(fcmToken.emptyIfNil)")
    }
}

// MARK: - DEBUG

#if DEBUG
extension AppDelegate {
    private func resetUserDefaultsIfNeeded() {
        if CommandLine.arguments.contains("-resetLocalStorage") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
    }
}
#endif
