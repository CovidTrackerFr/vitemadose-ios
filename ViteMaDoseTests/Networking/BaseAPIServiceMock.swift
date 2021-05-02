//
//  BaseAPIServiceMock.swift
//  ViteMaDoseTests
//
//  Created by Victor Sarda on 25/04/2021.
//

@testable import ViteMaDose
@testable import Moya

enum BaseAPIErrorMock: Error {
    case networkError
    case unknown
}

class BaseAPIServiceMock: BaseAPIServiceProvider {
    var provider: MoyaProvider<BaseAPI> = MoyaProvider<BaseAPI>()

    var fetchDepartmentsResult: Result<Counties, Error>?
    func fetchDepartments(completion: @escaping (Result<Counties, Error>) -> Void) {
        completion(fetchDepartmentsResult ?? .failure(BaseAPIErrorMock.unknown))
    }

    var fetchVaccinationCentresResult: Result<VaccinationCentres, Error>?
    func fetchVaccinationCentres(departmentCode: String, completion: @escaping (Result<VaccinationCentres, Error>) -> Void) {
        completion(fetchVaccinationCentresResult ?? .failure(BaseAPIErrorMock.unknown))
    }

    var fetchStatsResult: Result<Stats, Error>?
    func fetchStats(completion: @escaping (Result<Stats, Error>) -> Void) {
        completion(fetchStatsResult ?? .failure(BaseAPIErrorMock.unknown))
    }
}
