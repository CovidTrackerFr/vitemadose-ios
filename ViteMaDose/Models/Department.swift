//
//  Department.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

// MARK: - Department

struct Department: Codable, Equatable {
    let codeDepartement: String?
    let nomDepartement: String?
    let codeRegion: Int?
    let nomRegion: String?

    enum CodingKeys: String, CodingKey {
        case codeDepartement = "code_departement"
        case nomDepartement = "nom_departement"
        case codeRegion = "code_region"
        case nomRegion = "nom_region"
    }
}

// MARK: - Departments

typealias Departments = [Department]
