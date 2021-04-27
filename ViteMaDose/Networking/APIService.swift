//
//  APIService.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation
import APIRequest

protocol APIServiceProvider {
    @discardableResult
    func fetchCounties(completion: @escaping (Result<Counties, APIResponseStatus>) -> Void) -> APIRequest
    @discardableResult
    func fetchVaccinationCentres(country: String, completion: @escaping (Result<VaccinationCentres, APIResponseStatus>) -> Void) -> APIRequest
    @discardableResult
    func fetchStats(completion: @escaping (Result<Stats, APIResponseStatus>) -> Void) -> APIRequest
    @discardableResult
    func fetchContributors(completion: @escaping (Result<Credits, APIResponseStatus>) -> Void) -> APIRequest
}

struct APIService: APIServiceProvider {

    func fetchCounties(completion: @escaping (Result<Counties, APIResponseStatus>) -> Void) -> APIRequest {
        let configuration = APIConfiguration(host: RemoteConfiguration.shared.host)
        return APIRequest(
            "GET",
            path: RemoteConfiguration.shared.countiesListPath,
            configuration: configuration
        ).execute(Counties.self) { data, status in
            DispatchQueue.main.async {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(status))
                }
            }
        }
    }

    func fetchVaccinationCentres(country: String, completion: @escaping (Result<VaccinationCentres, APIResponseStatus>) -> Void) -> APIRequest {
        let configuration = APIConfiguration(host: RemoteConfiguration.shared.host)
        return APIRequest(
            "GET",
            path: RemoteConfiguration.shared.countyDataPath(for: country),
            configuration: configuration
        ).execute(VaccinationCentres.self) { data, status in
            DispatchQueue.main.async {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(status))
                }
            }
        }
    }

    func fetchStats(completion: @escaping (Result<Stats, APIResponseStatus>) -> Void) -> APIRequest {
        let configuration = APIConfiguration(host: RemoteConfiguration.shared.host)
        return APIRequest(
            "GET",
            path: RemoteConfiguration.shared.statsPath,
            configuration: configuration
        ).execute(Stats.self) { data, status in
            DispatchQueue.main.async {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(status))
                }
            }
        }
    }

    func fetchContributors(completion: @escaping (Result<Credits, APIResponseStatus>) -> Void) -> APIRequest {
        let configuration = APIConfiguration(host: RemoteConfiguration.shared.host)
        return APIRequest(
            "GET",
            path: RemoteConfiguration.shared.contributorsPath,
            configuration: configuration
        ).execute(Credits.self) { data, status in
            DispatchQueue.main.async {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(status))
                }
            }
        }
    }

}

extension APIResponseStatus: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error:
            return Localization.Error.Network.server_error
        case .offline:
            return Localization.Error.Network.offline
        default:
            return Localization.Error.Generic.default_message
        }
    }
}
