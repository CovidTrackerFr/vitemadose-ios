//
//  City.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 25/04/2021.
//

import Foundation
import MapKit

// MARK: - City

struct City: Codable {
    let nom: String?
    let centre: Centre?
    let departement: CityDepartement?

    enum CodingKeys: String, CodingKey {
        case nom
        case centre
        case departement
    }
}

// MARK: - Centre

struct Centre: Codable {
    let coordinates: [Double]

    enum CodingKeys: String, CodingKey {
        case coordinates
    }
}

extension City {
    var coordinates: LocationSearchResult.Coordinates? {
        guard
            let longitude = centre?.coordinates[safe: 0],
            let latitude = centre?.coordinates[safe: 1]
        else {
            return nil
        }
        return LocationSearchResult.Coordinates(
            latitude: latitude,
            longitude: longitude
        )
    }
}

// MARK: - City Departement

struct CityDepartement: Codable {
    let code: String?
    let nom: String?

    enum CodingKeys: String, CodingKey {
        case code
        case nom
    }
}

extension CityDepartement {
    var nearDepartments: [String]? {
        guard let code = self.code else { return nil }
        return NearDepartments.nearDepartmentsCodes(for: code)
    }
}

typealias Cities = [City]
