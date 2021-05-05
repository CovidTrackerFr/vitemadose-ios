//
//  String+Commons.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 23/04/2021.
//

import Foundation
import SwiftDate

extension String {
    static let space = " "
    static let commaWithSpace = ", "
    static let hyphen = "-"

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

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func format(_ args: CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }

    func format(_ args: [String]) -> String {
        return String(format: self, locale: .current, arguments: args)
    }

    func levDis(to string: String) -> Float {
        var firstString = self
        var secondString = string

        firstString = firstString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        secondString = secondString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        let empty = [Int](repeating: 0, count: secondString.count)
        var last = [Int](0...secondString.count)

        for (i, tLett) in firstString.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in secondString.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
            }
            last = cur
        }

        // maximum string length between the two
        let lowestScore = max(firstString.count, secondString.count)

        if let validDistance = last.last {
            return  1 - (Float(validDistance) / Float(lowestScore))
        }

        return 0.0
    }

    var stripped: String {
        return folding(options: .diacriticInsensitive, locale: nil)
            .folding(options: .caseInsensitive, locale: nil)
            .trimmingCharacters(in: .punctuationCharacters)
            .replacingOccurrences(of: String.hyphen, with: String.space)
    }
}
