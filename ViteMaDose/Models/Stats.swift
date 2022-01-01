// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

// MARK: - StatsValue

struct StatsValue: Codable, Equatable {
    let disponibles: Int
    let total: Int
    let creneaux: Int

    var pourcentage: Double? {
        total > 0 ? (Double(disponibles) * 100) / Double(total) : nil
    }

    enum CodingKeys: String, CodingKey {
        case disponibles
        case total
        case creneaux
    }
}

enum StatsKey: Equatable {
    case allDepartments
    case department(Int)

    var rawValue: String {
        switch self {
        case .allDepartments:
            return "tout_departement"
        case let .department(code):
            return String(code)
        }
    }
}

typealias Stats = [String: StatsValue]
