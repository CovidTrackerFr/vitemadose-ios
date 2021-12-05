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

// MARK: - SlotsPerCategory

public struct SlotsPerCategory: Codable {
    let category: Category?
    let slotsCount: Int?

    enum CodingKeys: String, CodingKey {
        case category = "tag"
        case slotsCount = "creneaux"
    }
}

extension SlotsPerCategory {
    enum Category: String, Codable {
        case all
        case firstOfSecondDose = "first_or_second_dose"
        case thirdDose = "third_dose"
        case unknown = "unknown_dose"
    }
}

// MARK: - Slot

public struct Slot: Codable {
    /// ID for the booking platform related to the location when slots are available (e.g. "mesoigner3031" ot "doctolib203443pid88863")
    let locationID: String?
    /// Number of available slots for a given category
    let slotsPerCategory: [SlotsPerCategory]?

    enum CodingKeys: String, CodingKey {
        case locationID = "lieu"
        case slotsPerCategory = "creneaux_par_tag"
    }
}

extension Slot {
    /// - Returns Bool: True if this `Slot` contains a booster shot tag with a positive number of slots ; false otherwise
    var hasThirdDoses: Bool {
        return dosesCount(for: .thirdDose) > 0
    }

    /// - Returns: The number of third shot / booster shot this slot have
    var thirdDosesCount: Int {
        let thirdDoseCategory = slotsPerCategory?.first(where: { $0.category == .thirdDose })
        return thirdDoseCategory?.slotsCount ?? .zero
    }

    func dosesCount(for category: SlotsPerCategory.Category) -> Int {
        let category = slotsPerCategory?.first(where: { $0.category == category })
        return category?.slotsCount ?? .zero
    }
}
