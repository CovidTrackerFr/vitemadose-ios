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

extension Optional where Wrapped: StringProtocol {
    var emptyIfNil: Wrapped {
        return self ?? ""
    }
}

// MARK: - String + A11Y

extension String {

    /// For the current string, returns a new version without numbers containing spaces.
    /// Thus big numbers which are basically written with whitespaces will be packed, and _VoiceOver_ will vocalize them as a whole single number
    /// and not a suite of individual digits.
    /// For example:
    ///     * a number "42000" will remain "42000" (llike a zip code)
    ///     * a number "687 713" will be converted to "687 713" (like a number of available slots)
    /// - Returns: The final string with "vocalizable" numbers
    public func forgeVocalizableText() -> String {
        var numbers = extractNumbers()
        return merge(inAll: &numbers, for: self)
    }

    /// Extract numbers from current string, supposing we don't know where they are.
    ///  The string is splitted by whitespaces. If we find an alone number word, we keep it. If wee find two consecutives or more number words, we merge them into one.
    /// - Returns: An array of string where each element is a number
    fileprivate func extractNumbers() -> [String] {
        var numbers = [String]()
        let words = self.split(separator: " ")
        for word in words where Int(word.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) != nil {
            numbers.append(String(word))
        }
        return numbers
    }

    /// For each _element_ in `numbers` for the given `string`,  removes the whitespace inside this _element_.
    /// Recursive version to avoid to have nested loops with too much iterations.
    /// - Parameters:
    ///     - numbers: Array of numbers to process, containing strings like "1234" and "123 456", modified at each call
    ///     - string: The string to process which will be smaller and smaller at each run
    /// - Returns: The result string, with non-numbers and numbrs without whitespaces
    fileprivate func merge(inAll numbers: inout [String], for string: String) -> String {
        guard numbers.count > 0 else {
            return string
        }
        var resultString = ""
        var fragments = string.components(separatedBy: numbers[0])
        if fragments.count > 0 {
            if !fragments[0].isEmpty { // Non-number fragment
                resultString += fragments[0] + numbers[0].filter { !$0.isWhitespace }
            }
            numbers.removeFirst() // One word less to process
            fragments.removeFirst() // No need to process begining of the string
            resultString += merge(inAll: &numbers, for: fragments.joined())
        }
        return resultString
    }
}
