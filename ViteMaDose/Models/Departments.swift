//
//  Departments.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 02/05/2021.
//

import Foundation

// MARK: - Department

struct Department: Codable, Equatable {
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
            let departments = data.decode([Department].self)
        else {
            assertionFailure("Departments should not be empty")
            return []
        }
        return departments
    }
}

extension Department {
    var asLocationSearchResult: LocationSearchResult {
        return LocationSearchResult(
            name: name,
            departmentCode: code,
            nearDepartmentCodes: [],
            coordinates: nil
        )
    }
}

// MARK: - Departments

typealias Departments = [Department]
