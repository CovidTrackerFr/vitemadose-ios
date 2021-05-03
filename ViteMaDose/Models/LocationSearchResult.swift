//
//  LocationSearchResult.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 02/05/2021.
//

import Foundation
import MapKit

struct LocationSearchResult: Codable, Equatable {
    let name: String
    let departmentCode: String
    let departmentCodes: [String]
    let coordinates: Coordinates?

    struct Coordinates: Codable, Equatable {
        let latitude: Double
        let longitude: Double
    }
}

extension LocationSearchResult.Coordinates {
    var asCCLocation: CLLocation {
        return CLLocation(
            latitude: CLLocationDegrees(latitude),
            longitude: CLLocationDegrees(longitude)
        )
    }
}
