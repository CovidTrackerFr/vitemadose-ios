//
//  APIService.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation
import APIRequest

protocol APIServiceProvider {
    
    func fetchCounties(completion: @escaping (Counties?, APIResponseStatus) -> ()) -> APIRequest
    func fetchVaccinationCentres(country: String, completion: @escaping (VaccinationCentres?, APIResponseStatus) -> ()) -> APIRequest
    func fetchStats(completion: @escaping (Stats?, APIResponseStatus) -> ()) -> APIRequest
    
}

struct APIService: APIServiceProvider {
    
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

extension APIResponseStatus: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
            case .error:
                return "Nous rencontrons des problèmes avec le serveur, veuillez réessayer plus tard."
            case .offline:
                return "Il semblerait que vous soyez hors ligne."
            default:
                return "Une erreur est survenue, veuillez réessayer plus tard."
        }
    }
    
}
