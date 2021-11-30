// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license.
//
// Author: Pierre-Yves LAPERSONNE et al.

import Foundation

// MARK: - Dated Slot

/// Simplifies the modelization of a slot (i.e. a location and slots numbers) for a date
public typealias DatedSlot = (date: String, slot: Slot)

// MARK: - Dated Slots For Centres

/// Permits to store for each vaccination centre the available slots at a specific day.
/// To consume less RAM, should be replaced in a next iteration by a [String: [DateSlot]] where the strings in keys are the `VaccinationCentre` identifiers.
public typealias DatedSlotsForCentres = [VaccinationCentre: [DatedSlot]]

// MARK: Dated Slots For Centres - Counts

extension DatedSlotsForCentres {

    /// Computes for each `DatedSlot` stored in this `DatedSlotsForCentres` the global count of appointments by looking for the `.all` `SlotTag` in each `Slot`.
    /// - Returns: Global number of appointments or 0 if nothing found.
    func allAppointmentsCount() -> Int {
        var total = 0
        for datedSlots in values {
            for datedSlot in datedSlots {
                total += datedSlot.slot.slotsPerTag?.first(where: { $0.tag == .all })?.slotsNumber ?? 0
            }
        }
        return total
    }

    /// Computes the global number of available centres stored in this `DatedSlotsForCentres`.
    /// - Returns: 0 if no available centre, or otherwise how many they are
    func allAvailableCentresCount() -> Int {
        var total = 0
        for centre in keys {
            total += centre.isAvailable ? 1 : 0
        }
        return total
    }

    /// Computes the global number of appointments for all the available `VaccinationCentre` in this `DatedSlotsForCentres`.
    /// - Returns: Int
    func availableCentresAppointmentsCount() -> Int {
        var total = 0
        for availableCentre in self.keys.filter({ $0.isAvailable }) {
            self[availableCentre]?.forEach({ datedSlot in
                total += datedSlot.slot.totalNumberOfShotsSlots()
            })
        }
        return total
    }
}

// MARK: - Date Slots For Centres - Booster Shots

extension DatedSlotsForCentres {

    /// Returns if there is some `Slot` with booster shots for the given `VaccinationCentre` in this `DatedSlotsForCentres`.
    /// - Parameter centre: The centre to look for booster shots
    /// - Returns: False if there is no centre stored in this `DatedSlotsForCentres` or if there is no booster shot, true if there are booster shots for this centre.
    func hasBoosterShot(for centre: VaccinationCentre) -> Bool {
        guard let datedSlotsForCentre = self[centre] else {
            return false
        }
        return datedSlotsForCentre.contains(where: { datedSlot in
            datedSlot.slot.hasBoosterShots()
        })
    }

    /// Counts the number of booster shots for the given `VaccinationCentre` at this specific `day`.
    /// - Parameters:
    ///     - centre: The vacination centre which must be stored in this `DatedSlotsForCentres`
    ///     - day: The day to look for booster shots, must have the same format as the `date` field of `Slot`
    /// - Returns: 0 if no centre found or no booster shots, otherwise the number of booster shots slots.
    func boosterShotsCount(for centre: VaccinationCentre, at day: String) -> Int {
        guard
            let datedSlotsForCentre = self[centre],
            let datedSlotForCentreAtDay = datedSlotsForCentre.first(where: { $0.date == day }) else {
            return 0
        }
        return datedSlotForCentreAtDay.slot.numberOfBoosterShotsSlots()
    }
    
    /// Counts the global number of appointments for  the given `VaccinationCentre` at this specific `day`.
    /// - Parameters:
    ///     - centre: The vacination centre which must be stored in this `DatedSlotsForCentres`
    ///     - day: The day to look for shots, must have the same format as the `date` field of `Slot`
    /// - Returns: 0 if no centre found or no shots available, otherwise the total number of shots.
    func appointmentsCount(for centre: VaccinationCentre, at day: String) -> Int {
        guard
            let datedSlotsForCentre = self[centre],
            let datedSlotForCentreAtDay = datedSlotsForCentre.first(where: { $0.date == day }) else {
            return 0
        }
        return datedSlotForCentreAtDay.slot.totalNumberOfShotsSlots()
    }
}
