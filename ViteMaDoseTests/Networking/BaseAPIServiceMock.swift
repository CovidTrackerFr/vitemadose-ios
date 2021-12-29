// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

@testable import ViteMaDose
@testable import Moya

enum BaseAPIErrorMock: Error {
    case networkError
    case unknown
}

final class BaseAPIServiceMock: BaseAPIServiceProvider {
    var provider: MoyaProvider<BaseAPI> = MoyaProvider<BaseAPI>()

    var fetchVaccinationCentresResult: Result<VaccinationCentres, Error>?
    func fetchVaccinationCentres(departmentCode: String, completion: @escaping (Result<VaccinationCentres, Error>) -> Void) {
        completion(fetchVaccinationCentresResult ?? .failure(BaseAPIErrorMock.unknown))
    }

    var fetchStatsResult: Result<Stats, Error>?
    func fetchStats(completion: @escaping (Result<Stats, Error>) -> Void) {
        completion(fetchStatsResult ?? .failure(BaseAPIErrorMock.unknown))
    }
}
