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

extension LocationSearchResult {
    func filterVaccinationCentreByDistance(vaccinationCentre: VaccinationCentre) -> Bool {
        guard
            let searchResultLocation = coordinates?.asCCLocation,
            let vaccinationCentreCoordinates = vaccinationCentre.locationAsCLLocation
        else {
            return true
        }
        return searchResultLocation.distance(from: vaccinationCentreCoordinates) <= AppConstant.maximumVaccinationCentresDistanceInMeters
    }

    func sortVaccinationCentresByLocation(_ lhs: VaccinationCentre, _ rhs: VaccinationCentre) -> Bool {
        guard
            let baseLocation = coordinates?.asCCLocation,
            let lhsLocation = lhs.locationAsCLLocation,
            let rhsLocation = rhs.locationAsCLLocation
        else {
            return false
        }
        return lhsLocation.distance(from: baseLocation) < rhsLocation.distance(from: baseLocation)
    }
}
