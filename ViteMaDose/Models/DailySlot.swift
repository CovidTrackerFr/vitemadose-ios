//
//  DailySlot.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 04/12/2021.
//

import Foundation

// MARK: - Daily Slot

public struct DailySlot: Codable {

    // Date in yyyy-mm-dd format when there are daily slots
    let date: String?
    /// Total count of available slots
    let total: Int?
    let slotsPerLocation: [Slot]?

    enum CodingKeys: String, CodingKey {
        case date
        case total
        case slotsPerLocation = "creneaux_par_lieu"
    }
}

// MARK: - Slot

public struct Slot: Codable {

    /// ID for the booking platform related to the location when slots are available (e.g. "mesoigner3031" ot "doctolib203443pid88863")
    let locationID: String?
    /// Number of available slots for a given category
    let slotsPerCategory: [Category]?

    enum CodingKeys: String, CodingKey {
        case locationID = "lieu"
        case slotsPerCategory = "creneaux_par_tag"
    }
}

extension Slot {
    enum Category: String, Codable {
        case all
        case thirdDose = "third_dose"
        case unknown = "unknown_dose"
    }
}
