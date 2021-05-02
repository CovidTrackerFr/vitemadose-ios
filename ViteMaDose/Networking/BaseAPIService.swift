//
//  GeoAPIService.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation
import Moya

// MARK: - Geo API

enum GeoAPI {
    case citiesByName(name: String)
    case citiesByPostCode(postCode: String)
}

extension GeoAPI: TargetType {
    static let limit = "15"
    var baseURL: URL {
        return URL(staticString: "https://geo.api.gouv.fr/")
    }

    var path: String {
        switch self {
        case .citiesByName,
             .citiesByPostCode:
            return "communes"
        }
    }

    var method: Moya.Method {
        switch self {
        case .citiesByName,
             .citiesByPostCode:
            return .get
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case let .citiesByName(name):
            return .requestParameters(
                parameters: [
                    "nom": name,
                    "fields": "departement,centre",
                    "limit": Self.limit
                ],
                encoding: URLEncoding.queryString
            )
        case let .citiesByPostCode(postCode):
            return .requestParameters(
                parameters: [
                    "codePostal": postCode,
                    "fields": "departement, centres",
                    "limit": Self.limit
                ],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - API Service

protocol GeoAPIServiceProvider: AnyObject {
    var provider: MoyaProvider<GeoAPI> { get }

    func fetchCities(byPostCode code: String, completion: @escaping (Cities) -> Void)
    func fetchCities(byName name: String, completion: @escaping (Cities) -> Void)
}

class GeoAPIService: GeoAPIServiceProvider {
    let provider: MoyaProvider<GeoAPI>

    init(provider: MoyaProvider<GeoAPI> = MoyaProvider<GeoAPI>()) {
        self.provider = provider
    }

    func fetchCities(byPostCode code: String, completion: @escaping (Cities) -> Void) {
        request(target: .citiesByPostCode(postCode: code), completion: completion)
    }

    func fetchCities(byName name: String, completion: @escaping (Cities) -> Void) {
        request(target: .citiesByName(name: name), completion: completion)
    }
}

// MARK: - Decode

private extension GeoAPIService {
    private func request(target: GeoAPI, completion: @escaping (Cities) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let cities = try JSONDecoder().decode(Cities.self, from: filteredResponse.data)
                    completion(cities)
                } catch {
                    completion([])
                }
            case .failure:
                completion([])
            }
        }
    }
}
