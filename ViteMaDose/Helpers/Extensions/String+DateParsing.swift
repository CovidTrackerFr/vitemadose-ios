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
        if let date = self.toDate(nil, region: region) {
            return date.toString(style)
        } else if let isoDate = self.toISODate(nil, region: region) {
            return isoDate.toString(style)
        }

        return nil
    }
}
