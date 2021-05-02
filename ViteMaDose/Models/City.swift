//
//  City.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 25/04/2021.
//

import Foundation

// MARK: - City
struct City: Codable {
    let nom: String?
    let code: String?
    let departement: Departement?

    enum CodingKeys: String, CodingKey {
        case nom
        case code
        case departement
    }
}

// MARK: - Departement
struct Departement: Codable {
    let code: String?
    let nom: String?

    enum CodingKeys: String, CodingKey {
        case code
        case nom
    }
}

typealias Cities = [City]
