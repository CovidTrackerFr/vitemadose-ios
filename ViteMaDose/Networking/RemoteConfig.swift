// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license.
//
// Author: Paul JEANNOT et al.

import Foundation
import FirebaseRemoteConfig

// MARK: - Remote Configuration

struct RemoteConfiguration {

    static let shared = RemoteConfiguration()
    let configuration: RemoteConfig

    private init() {
        configuration = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()

        configuration.setDefaults(fromPlist: "remote-configuration")
        settings.minimumFetchInterval = 3600
        configuration.configSettings = settings
    }

    func synchronize(completion: @escaping (Result<Void, Error>) -> Void) {
        configuration.fetch(withExpirationDuration: 0) { _, error in
            if let error = error {
                print("[RemoteConfiguration] Error while fetching remote configuration (\(error.localizedDescription)).")
                completion(.failure(error))
            } else {
                configuration.activate()
                print("[RemoteConfiguration] Successfully fetched remote configuration.")
                completion(.success(()))
            }
        }
    }
}

// MARK: - Defaults values

extension RemoteConfiguration {

    var baseUrl: String {
        return configuration.configValue(forKey: "url_base").stringValue!
        //return "http://192.168.1.13:8888/"
    }

    var statsPath: String {
        return configuration.configValue(forKey: "path_stats").stringValue!
    }

    var departmentsPath: String {
        return configuration.configValue(forKey: "path_list_departments").stringValue!
    }

    var maintenanceModeUrl: String? {
        let configValue = configuration.configValue(forKey: "ios_maintenance_mode_url").stringValue
        if let value = configValue, !value.isEmpty {
            return configValue
        } else {
            return nil
        }
    }

    var dataDisclaimerEnabled: Bool {
        return configuration.configValue(forKey: "data_disclaimer_enabled").boolValue
    }

    var dataDisclaimerMessage: String? {
        let configValue = configuration.configValue(forKey: "data_disclaimer_message").stringValue
        if let value = configValue, !value.isEmpty {
            return value
        } else {
            return nil
        }
    }

    var vaccinationCentresListRadiusInKm: NSNumber {
        return configuration.configValue(forKey: "vaccination_centres_list_radius_in_km").numberValue
    }

    var boostershotMinCount: Int {
        return configuration.configValue(forKey: "boostershot_min_count").numberValue.intValue
    }

    var vaccinationCentresListRadiusInMeters: Double {
        return vaccinationCentresListRadiusInKm.doubleValue * 1000
    }

    func dailySlots(withCode code: String) -> String {
        let path = configuration.configValue(forKey: "path_daily_slots").stringValue!
        return path.replacingOccurrences(of: "{code}", with: code)
    }

    func departmentPath(withCode code: String) -> String {
        let path = configuration.configValue(forKey: "path_data_department").stringValue!
        return path.replacingOccurrences(of: "{code}", with: code)
    }
}
