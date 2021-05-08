//
//  BaseAPIService.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 01/05/2021.
//

import Foundation
import Moya

// MARK: - Base API

enum BaseAPI {
    case stats
    case credits
    case vaccinationCentres(departmentCode: String)
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
        }
    }

    var method: Moya.Method {
        switch self {
        case .stats,
             .credits,
             .vaccinationCentres:
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
             .vaccinationCentres:
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
}

class BaseAPIService: BaseAPIServiceProvider {
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
             .vaccinationCentres:
            return .reloadIgnoringLocalCacheData
        }
    }
}
