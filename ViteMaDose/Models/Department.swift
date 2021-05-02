//
//  Department.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

// MARK: - Department

struct Department: Codable, Equatable {
    let codeDepartement: String
    let nomDepartement: String?

    enum CodingKeys: String, CodingKey {
        case codeDepartement = "code_departement"
        case nomDepartement = "nom_departement"
    }
}

extension Department {
    var asLocationSearchResult: LocationSearchResult {
        return LocationSearchResult(
            name: nomDepartement ?? "",
            departmentCode: codeDepartement,
            departmentCodes: [],
            location: nil
        )
    }
}

// MARK: - Departments

typealias Departments = [Department]
