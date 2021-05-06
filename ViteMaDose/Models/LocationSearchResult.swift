//
//  LocationSearchResult.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 02/05/2021.
//

import Foundation
import MapKit

struct LocationSearchResult: Codable, Hashable {
    let name: String
    let postCode: String?
    let departmentCode: String
    let nearDepartmentCodes: [String]
    let coordinates: Coordinates?

    struct Coordinates: Codable, Hashable {
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
    /// Returns the search result name with post code
    var formattedName: String {
        if let postCode = postCode {
            return "\(name) (\(postCode))"
        }
        return name
    }

    /// Sort by best match from a query using Levenshtein distance score
    static var sortByBestMatch: (_ query: String, Self, Self) -> Bool = {
        return $0.levDis(to: $1.name) > $0.levDis(to: $2.name)
    }

    static var filterDepartmentsByQuery: (_ query: String, Self) -> Bool = {
        let query = $0.stripped
        let name = $1.name.stripped
        let departmentCode = $1.departmentCode
        let departmentNameContainsQuery = name.range(of: query) != nil
        let departmentCodeContainsQuery = departmentCode.contains(query)
        return departmentNameContainsQuery || departmentCodeContainsQuery
    }

    func filterVaccinationCentreByDistance(vaccinationCentre: VaccinationCentre) -> Bool {
        guard
            let searchResultLocation = coordinates?.asCCLocation,
            let vaccinationCentreCoordinates = vaccinationCentre.locationAsCLLocation
        else {
            return true
        }
        return searchResultLocation.distance(from: vaccinationCentreCoordinates) <= RemoteConfiguration.shared.vaccinationCentresListRadiusInMeters
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

    func sortVaccinationCentresByAppointment(_ lhs: VaccinationCentre, _ rhs: VaccinationCentre) -> Bool {
        guard
            let lhsDate = lhs.nextAppointmentDate,
            let rhsDate = rhs.nextAppointmentDate,
            lhs.isAvailable,
            rhs.isAvailable
        else {
            return false
        }
        return lhsDate.isBeforeDate(rhsDate, granularity: .minute)
    }
}
