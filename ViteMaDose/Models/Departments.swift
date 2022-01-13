// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

// MARK: - Department

struct Department: Codable, Hashable {
    var name: String
    var code: String

    enum CodingKeys: String, CodingKey {
        case name = "nom"
        case code
    }

    private static let fileName = "departments"

    static var list: [Department] {
        guard
            let url = Bundle.main.url(forResource: Self.fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            case let .success(departments) = data.decode([Department].self)
        else {
            assertionFailure("Departments should not be empty")
            return []
        }
        return departments.uniqued()
    }
}

extension Department {
    var asLocationSearchResult: LocationSearchResult {
        return LocationSearchResult(
            name: name,
            postCode: nil,
            selectedDepartmentCode: code,
            departmentCodes: [],
            coordinates: nil
        )
    }
}

// MARK: - Departments

typealias Departments = [Department]
