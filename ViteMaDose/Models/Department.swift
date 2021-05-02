//
//  Department.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

// MARK: - Department

struct DepartmentLegacy: Codable, Equatable {
    let codeDepartement: String
    let nomDepartement: String?

    enum CodingKeys: String, CodingKey {
        case codeDepartement = "code_departement"
        case nomDepartement = "nom_departement"
    }
}

// MARK: - Departments

typealias Departments = [Department]
