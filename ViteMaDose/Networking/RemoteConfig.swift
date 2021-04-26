//
//  RemoteConfig.swift
//  ViteMaDose
//
//  Created by Paul on 14/04/2021.
//

import Foundation
import FirebaseRemoteConfig
import APIRequest

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
    var host: String {
        return baseUrl.replacingOccurrences(of: "https://", with: "")
    }

    var baseUrl: String {
        return configuration.configValue(forKey: "url_base").stringValue!
    }

    var statsPath: String {
        return configuration.configValue(forKey: "path_stats").stringValue!
    }

    var countiesListPath: String {
        return configuration.configValue(forKey: "path_list_departments").stringValue!
    }

    var maintenanceModeUrl: String? {
        let configValue = configuration.configValue(forKey: "ios_maintenance_mode_url").stringValue ?? ""
        guard !configValue.isEmpty else {
            return nil
        }
        return configValue
    }

    func countyDataPath(for county: String) -> String {
        let path = configuration.configValue(forKey: "path_data_department").stringValue!
        return path.replacingOccurrences(of: "{code}", with: county)
    }

}
