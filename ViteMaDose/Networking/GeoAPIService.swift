// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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
                    "fields": "codesPostaux,departement,centre",
                    "limit": Self.limit
                ],
                encoding: URLEncoding.queryString
            )
        case let .citiesByPostCode(postCode):
            return .requestParameters(
                parameters: [
                    "codePostal": postCode,
                    "fields": "codesPostaux,departement,centre",
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

final class GeoAPIService: GeoAPIServiceProvider {
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
            var citiesResult: Cities = []
            switch result {
            case let .success(response):
                let filteredResponse = try? response.filterSuccessfulStatusCodes()
                if case let .success(cities) = filteredResponse?.data.decode(Cities.self) {
                    citiesResult = cities
                }
            default:
                break
            }
            completion(citiesResult)
        }
    }
}
