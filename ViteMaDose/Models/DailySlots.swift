// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license.
//
// Author: Pierre-Yves LAPERSONNE et al.

import Foundation

// MARK: - Daily Slots For Location

/// Allows to gather for a departement all the daily slots sent by the backend.
public struct DailySlotsForDistrict: Codable {

    /// Location code for the department, e.g. 31 for Haute-Garonne
    let locationCode: String?
    /// Daily slots for this department
    let dailySlots: [DailySlot]?

    enum CodingKeys: String, CodingKey {
        case locationCode = "departement"
        case dailySlots = "creneaux_quotidiens"
    }
}

extension DailySlotsForDistrict {

    /// For the given center, returns the number of booster shot slots
    /// - Parameter center: The center to use for filtering
    /// - Returns: Number of slots
    func numberOfBoosterShotSlots(for center: VaccinationCentre) -> Int {
        var total = 0
        guard let dailySlots = dailySlots, let centerIdentfier = center.internalId else {
            return total
        }
        for slot in dailySlots {
            total += slot.numberOfBoosterShotSlots(for: centerIdentfier)
        }
        return total
    }

    /// Returns the slots for the given day.
    /// - Parameter day: The date to use for filtering
    /// - Returns: Aerray of `DailySlot`, can be empty if nothing found for this `day`
    func slots(for day: String) -> [DailySlot] {
        guard let dailySlots = dailySlots, !day.isEmpty else {
            return []
        }
        return dailySlots.filter({ $0.formalizedDay == day })
    }
}

// MARK: - Daily Slot

/// A daily slot gathers for a specific date the number of available slots and details about them.
public struct DailySlot: Codable {

    /// Date in yyyy-mm-dd format when there are daily slots
    let date: String?
    /// Global count of available slots for all the locations
    let total: Int?
    /// Gathers the number of slots for a specific location
    let slotsPerLocation: [Slot]?

    enum CodingKeys: String, CodingKey {
        case date
        case total
        case slotsPerLocation = "creneaux_par_lieu"
    }
}

extension DailySlot {

    /// Converted date in format "2021-12-02T09:16:00+01:00" to "2 décembre 2021"
    var formalizedDay: String {
        date?.toString(with: .date(.long), region: AppConstant.franceRegion) ?? ""
    }

    /// Using the given location, supposed to be a vaccination center internal identifier, returns the number of slots for a third / booster shot
    /// - Parameter location: Location to use for filtering the `slotsPerLocation`
    /// - Returns: The number of slots for booster shots
    func numberOfBoosterShotSlots(for location: String) -> Int {
        guard !location.isEmpty, let slotsForThisLocation = slotsPerLocation?.filter({ $0.location == location}) else {
            return 0
        }
        var count = 0
        for slot in slotsForThisLocation {
            count += slot.numberOfBoosterShotsSlots()
        }
        return count
    }
}

// MARK: - Slot

public struct Slot: Codable {

    /// Code for the booking platform related to the location when there are slots (e.g. "mesoigner3031" ot "doctolib203443pid88863")
    let location: String?
    /// Gathers number of available slots for specific tags
    let slotsPerTag: [SlotsPerTag]?

    enum CodingKeys: String, CodingKey {
        case location = "lieu"
        case slotsPerTag = "creneaux_par_tag"
    }
}

extension Slot {

    /// - Returns Bool: True if this `Slot` contains a booster shot tag with a positive number of slots ; false otherwise
    func hasBoosterShots() -> Bool {
        numberOfBoosterShotsSlots() > 0
    }

    /// - Returns: The number of third shot / booster shot this slot have
    func numberOfBoosterShotsSlots() -> Int {
        guard let slotsPerTag = slotsPerTag,
              let boosterShotTag = slotsPerTag.first(where: { $0.tag == .thirdShot }),
              let slotsNumber = boosterShotTag.slotsNumber else {
            return 0
        }
        return slotsNumber
    }

    /// - Returns: The global number of shots this slot have
    func totalNumberOfShotsSlots() -> Int {
        guard let slotsPerTag = slotsPerTag,
              let boosterShotTag = slotsPerTag.first(where: { $0.tag == .all }),
              let slotsNumber = boosterShotTag.slotsNumber else {
            return 0
        }
        return slotsNumber
    }
}

// MARK: - Slots Per Tag

public struct SlotsPerTag: Codable {

    /// Define if the slots are for third dose, first or second, or all.
    let tag: SlotTag?
    /// Number of slots corresponding to the defined tag`
    let slotsNumber: Int?

    enum CodingKeys: String, CodingKey {
        case tag
        case slotsNumber = "creneaux"
    }
}

// MARK: - Slot Tag

public enum SlotTag: String, Codable {
    case all = "all"
    case firstOrSecondShot = "first_or_second_dose"
    case thirdShot = "third_dose"
    case unknownShot = "unknown_dose"
}
