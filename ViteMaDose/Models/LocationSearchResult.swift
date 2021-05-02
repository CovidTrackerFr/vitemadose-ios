//
//  LocationSearchResult.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 02/05/2021.
//

import Foundation
import MapKit

struct LocationSearchResult {
    let name: String
    let departmentCode: String
    let departmentCodes: [String]
    let location: CLLocation?
}
