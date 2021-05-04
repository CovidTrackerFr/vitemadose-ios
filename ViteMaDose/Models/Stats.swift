//
//  Stats.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 10/04/2021.
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
