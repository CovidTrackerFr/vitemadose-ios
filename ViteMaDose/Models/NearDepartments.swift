//
//  NearDepartments.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 02/05/2021.
//

import Foundation

// MARK: - NearDepartments

struct NearDepartments {
    private static let fileName = "near_departments"

    private static var nearDepartmentsList: [String: [String]] {
        guard
            let url = Bundle.main.url(forResource: Self.fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            case let .success(nearDepartmentsList) = data.decode([String: [String]].self)
        else {
            assertionFailure("Near departments should not be empty")
            return [:]
        }
        return nearDepartmentsList
    }

    static func nearDepartmentsCodes(for code: String) -> [String] {
        return nearDepartmentsList[code] ?? []
    }
}
