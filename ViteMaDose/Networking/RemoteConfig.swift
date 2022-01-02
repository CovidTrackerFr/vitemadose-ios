// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import FirebaseRemoteConfig

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
                print("Error while fetching remote configuration (\(error.localizedDescription)).")
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

    var chronodoseMinCount: Int {
        return configuration.configValue(forKey: "chronodose_min_count").numberValue.intValue
    }

    var vaccinationCentresListRadiusInMeters: Double {
        return vaccinationCentresListRadiusInKm.doubleValue * 1000
    }

    var contributorsPath: String {
        return configuration.configValue(forKey: "path_contributors").stringValue!
    }

    func departmentPath(withCode code: String) -> String {
        let path = configuration.configValue(forKey: "path_data_department").stringValue!
        return path.replacingOccurrences(of: "{code}", with: code)
    }

    func departmentSlotsPath(withCode code: String) -> String {
        let path = configuration.configValue(forKey: "path_departement_slots").stringValue!
        return path.replacingOccurrences(of: "{code}", with: code)
    }
}
