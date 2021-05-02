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
    let codePostal: String?
    let centre: Centre?
    let departement: Departement?

    enum CodingKeys: String, CodingKey {
        case nom
        case codePostal = "code"
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
    var location: CLLocation? {
        guard
            let longitude = centre?.coordinates[safe: 0],
            let latitude = centre?.coordinates[safe: 1]
        else {
            return nil
        }
        return CLLocation(
            latitude: CLLocationDegrees(latitude),
            longitude: CLLocationDegrees(longitude)
        )
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
