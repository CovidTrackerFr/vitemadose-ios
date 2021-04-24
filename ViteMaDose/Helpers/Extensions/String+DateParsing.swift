//
//  Date+Parsing.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 23/04/2021.
//

import Foundation
import SwiftDate

extension String {
    /// Parse a date with an undefined format
    /// This function will try to parse the `String` as a Date
    /// using `SwiftDate`.
    /// If parsing fails, it will try to parse as an `ISO` date as a fallback
    /// - Parameter region: custom option `Region`
    /// - Returns: optional `Date`
    func toString(with style: DateToStringStyles, region: Region) -> String? {
        let date = toDate(nil, region: region) ?? toISODate(nil, region: region)
        return date?.toString(style)
    }

    // Localization
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }

    func format(_ args: CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }

    func format(_ args: [String]) -> String {
        return String(format: self, locale: .current, arguments: args)
    }
}
