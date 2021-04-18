//
//  APIService.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation
import APIRequest

struct APIService {
    
    func fetchCounties(completion: @escaping (Counties?, APIResponseStatus) -> ()) -> APIRequest {
        return APIRequest("GET", path: RemoteConfiguration.shared.countiesListPath, configuration: APIConfiguration(host: RemoteConfiguration.shared.host)).execute(Counties.self) { data, status in
            DispatchQueue.main.async {
                completion(data, status)
            }
        }
    }
    
    func fetchVaccinationCentres(country: String, completion: @escaping (VaccinationCentres?, APIResponseStatus) -> ()) -> APIRequest {
        return APIRequest("GET", path: RemoteConfiguration.shared.countyDataPath(for: country), configuration: APIConfiguration(host: RemoteConfiguration.shared.host)).execute(VaccinationCentres.self) { data, status in
            DispatchQueue.main.async {
                completion(data, status)
            }
        }
    }

    func fetchStats(completion: @escaping (Stats?, APIResponseStatus) -> ()) -> APIRequest {
        return APIRequest("GET", path: RemoteConfiguration.shared.statsPath, configuration: APIConfiguration(host: RemoteConfiguration.shared.host)).execute(Stats.self) { data, status in
            DispatchQueue.main.async {
                completion(data, status)
            }
        }
    }
    
}

extension APIResponseStatus: Error {
    
    var localizedDescription: String {
        switch self {
            case .error:
                return "We are having troubles with our server right now. Please try again later"
            case .offline:
                return "Your Internet connection appears to be offline."
            default:
                return "An error occurred, please try again"
        }
    }
    
}
