// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license.
//
// Author: Victor SARDA et al.

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
        let topicName = centreTopicName(departmentCode: departmentCode, centreId: centreId)
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
        completion: @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        let topicName = centreTopicName(departmentCode: departmentCode, centreId: centreId)
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

    private func centreTopicName(departmentCode: String, centreId: String) -> String {
        return "department_\(departmentCode)_center_\(centreId)"
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
