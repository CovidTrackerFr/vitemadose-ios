//
//  FCMHelper.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/05/2021.
//

import Firebase
import Foundation
import UIKit

struct FCMHelper {
    static let shared = FCMHelper()
    private init() {}

    func subscribeToCentreTopic(
        withDepartmentCode departmentCode: String,
        andCentreId centreId: String,
        completion: @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        Messaging.messaging().subscribe(toTopic: centreTopicName(departmentCode, centreId)) { error in
            if let error = error {
                Log.e("SUBSCRIBE ERROR: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                Log.i("SUBSCRIBE SUCCESS: \(centreTopicName(departmentCode, centreId))")
                completion(.success(()))
            }
        }
    }

    func unsubscribeToCentreTopic(
        withDepartmentCode departmentCode: String,
        andCentreId centreId: String,
        completion: @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        Messaging.messaging().unsubscribe(fromTopic: centreTopicName(departmentCode, centreId)) { error in
            if let error = error {
                Log.e("UNSUBSCRIBE ERROR: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                Log.i("UNSUBSCRIBE SUCCESS: \(centreTopicName(departmentCode, centreId))")
                completion(.success(()))
            }
        }
    }

    private var centreTopicName: (String, String) -> String = {
        return "department_\($0)_center_\($1)"
    }

    func requestNotificationsAuthorizationIfNeeded(
        _ notificationCenter: UNUserNotificationCenter = .current(),
        completion: (() -> Void)? = nil
    ) {
        notificationCenter.getNotificationSettings { settings in
            guard case .notDetermined = settings.authorizationStatus else {
                completion?()
                return
            }

            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
                if let error = error {
                    Log.e("Push authorisation request error \(error.localizedDescription)")
                }

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }

                completion?()
            }
        }
    }
}
