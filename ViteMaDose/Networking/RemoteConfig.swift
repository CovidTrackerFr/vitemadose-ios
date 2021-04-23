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

    func synchronize(completion: @escaping (APIResponseStatus) -> Void) {
        configuration.fetch(withExpirationDuration: 0) { (_, error) in
            guard error == nil else {
                print("Error while fetching remote configuration (\(error.debugDescription)).")
                completion(.error)
                return
            }

            configuration.activate()
            print("[RemoteConfiguration] Successfully fetched remote configuration.")
            completion(.ok)
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

    func countyDataPath(for county: String) -> String {
        let path = configuration.configValue(forKey: "path_data_department").stringValue!
        return path.replacingOccurrences(of: "{code}", with: county)
    }
}
