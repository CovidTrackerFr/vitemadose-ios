//
//  AppConstant.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 03/05/2021.
//

import Foundation
import SwiftDate

enum AppConstant {
    static let franceRegion = Region(
        calendar: Calendar.current,
        zone: Zones.current,
        locale: Locale(identifier: "fr_FR")
    )
}
