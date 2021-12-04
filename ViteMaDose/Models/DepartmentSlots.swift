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

