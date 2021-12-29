// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import Moya

// MARK: - Base API

enum BaseAPI {
    case stats
    case credits
    case vaccinationCentres(departmentCode: String)
    case departmentSlots(departmentCode: String)
}

extension BaseAPI: TargetType {
    private static let remoteConfig = RemoteConfiguration.shared

    var baseURL: URL {
        let urlString = Self.remoteConfig.baseUrl
        return URL(staticString: urlString)
    }

    var path: String {
        switch self {
        case .stats:
            return Self.remoteConfig.statsPath
        case .credits:
            return Self.remoteConfig.contributorsPath
        case let .vaccinationCentres(code):
            return Self.remoteConfig.departmentPath(withCode: code)
        case let .departmentSlots(code):
            return Self.remoteConfig.departmentSlotsPath(withCode: code)
        }
    }

    var method: Moya.Method {
        switch self {
        case .stats,
             .credits,
             .vaccinationCentres,
             .departmentSlots:
            return .get
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var task: Task {
        switch self {
        case .stats,
             .credits,
             .vaccinationCentres,
             .departmentSlots:
            return .requestPlain
        }
    }

    var validationType: ValidationType {
        return .successCodes
    }
}

// MARK: - Base API Service

protocol BaseAPIServiceProvider: AnyObject {
    var provider: MoyaProvider<BaseAPI> { get }

    func fetchVaccinationCentres(departmentCode: String, completion: @escaping (Result<VaccinationCentres, Error>) -> Void)
    func fetchStats(completion: @escaping (Result<Stats, Error>) -> Void)
    func fetchCredits(completion: @escaping (Result<Credits, Error>) -> Void)
    func fetchDepartmentSlots(departmentCode: String, completion: @escaping (Result<DepartmentSlots, Error>) -> Void)
}

final class BaseAPIService: BaseAPIServiceProvider {
    let provider: MoyaProvider<BaseAPI>

    init(provider: MoyaProvider<BaseAPI> = MoyaProvider<BaseAPI>(plugins: [CachePolicyPlugin()])) {
        self.provider = provider
    }

    func fetchStats(completion: @escaping (Result<Stats, Error>) -> Void) {
        request(target: .stats, completion: completion)
    }

    func fetchCredits(completion: @escaping (Result<Credits, Error>) -> Void) {
        request(target: .credits, completion: completion)
    }

    func fetchVaccinationCentres(departmentCode: String, completion: @escaping (Result<VaccinationCentres, Error>) -> Void) {
        request(target: .vaccinationCentres(departmentCode: departmentCode), completion: completion)
    }

    func fetchDepartmentSlots(departmentCode: String, completion: @escaping (Result<DepartmentSlots, Error>) -> Void) {
        request(target: .departmentSlots(departmentCode: departmentCode), completion: completion)
    }
}

// MARK: - Decode

private extension BaseAPIService {
    private func request<T: Codable>(target: BaseAPI, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                completion(response.data.decode(T.self))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Cache Policy

extension BaseAPI: CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .stats,
             .credits,
             .vaccinationCentres,
             .departmentSlots:
            return .reloadIgnoringLocalCacheData
        }
    }
}
