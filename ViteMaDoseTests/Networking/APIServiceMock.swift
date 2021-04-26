//
//  APIServiceMock.swift
//  ViteMaDoseTests
//
//  Created by Victor Sarda on 25/04/2021.
//

@testable import ViteMaDose
@testable import APIRequest

class APIServiceMock: APIServiceProvider {
    static let request = APIRequest("", path: "", configuration: APIConfiguration(host: ""))

    var fetchCountiesResult: Result<Counties, APIResponseStatus>?
    func fetchCounties(completion: @escaping (Result<Counties, APIResponseStatus>) -> Void) -> APIRequest {
        if let result = fetchCountiesResult {
            completion(result)
        } else {
            completion(.failure(APIResponseStatus.error))
        }

        return Self.request
    }

    var fetchVaccinationCentresResult: Result<VaccinationCentres, APIResponseStatus>?
    func fetchVaccinationCentres(country: String, completion: @escaping (Result<VaccinationCentres, APIResponseStatus>) -> Void) -> APIRequest {
        if let result = fetchVaccinationCentresResult {
            completion(result)
        } else {
            completion(.failure(APIResponseStatus.error))
        }

        return Self.request
    }

    var fetchStatsResult: Result<Stats, APIResponseStatus>?
    func fetchStats(completion: @escaping (Result<Stats, APIResponseStatus>) -> Void) -> APIRequest {
        if let result = fetchStatsResult {
            completion(result)
        } else {
            completion(.failure(APIResponseStatus.error))
        }

        return Self.request
    }
}
