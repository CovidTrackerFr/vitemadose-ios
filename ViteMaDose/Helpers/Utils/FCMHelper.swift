// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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
        chronoDosesOnly: Bool,
        completion: @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        let topicName = centreTopicName(departmentCode: departmentCode, centreId: centreId, chronoDosesOnly: chronoDosesOnly)
        Messaging.messaging().subscribe(toTopic: topicName) { error in
            if let error = error {
                Log.e("SUBSCRIBE ERROR: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                Log.i("SUBSCRIBE SUCCESS: \(topicName)")
                completion(.success(()))
            }
        }
    }

    func unsubscribeToCentreTopic(
        withDepartmentCode departmentCode: String,
        andCentreId centreId: String,
        chronoDosesOnly: Bool,
        completion: @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        let topicName = centreTopicName(departmentCode: departmentCode, centreId: centreId, chronoDosesOnly: chronoDosesOnly)
        Messaging.messaging().unsubscribe(fromTopic: topicName) { error in
            if let error = error {
                Log.e("UNSUBSCRIBE ERROR: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                Log.i("UNSUBSCRIBE SUCCESS: \(topicName)")
                completion(.success(()))
            }
        }
    }

    private func centreTopicName(departmentCode: String, centreId: String, chronoDosesOnly: Bool) -> String {
        let topicName = "department_\(departmentCode)_center_\(centreId)"
        if chronoDosesOnly {
            return topicName.appending("_chronodoses")
        }
        return topicName
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
