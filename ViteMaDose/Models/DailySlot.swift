// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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
        case kidsFirstDose = "kids_first_dose"
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

    func dosesCount(for category: SlotsPerCategory.Category) -> Int {
        let category = slotsPerCategory?.first(where: { $0.category == category })
        return category?.slotsCount ?? .zero
    }
}
