//
//  DepartmentSlots.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 04/12/2021.
//

import Foundation

// MARK: - Daily Slots

public struct DepartmentSlots: Codable {
    let departmentNumber: String?
    let dailySlots: [DailySlot]?

    enum CodingKeys: String, CodingKey {
        case departmentNumber = "departement"
        case dailySlots = "creneaux_quotidiens"
    }
}

extension DepartmentSlots {
    var allSlotsCount: Int {
        guard let dailySlots = dailySlots else {
            return .zero
        }
        return dailySlots.reduce(0) { $0 + ($1.total ?? .zero) }
    }
}

extension Array where Element == DepartmentSlots {
    var allSlotsCount: Int {
        return reduce(0) { $0 + $1.allSlotsCount }
    }
}
