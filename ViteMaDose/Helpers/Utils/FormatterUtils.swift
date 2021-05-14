//
//  FormatterUtils.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 24/04/2021.
//

import Foundation

extension Formatter {
    static let withSeparator: Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = String.space
        formatter.locale = .current
        return formatter
    }()

    static let withPercentage: Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.locale = .current
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self).emptyIfNil }
}

extension Numeric where Self == Double {
    var formattedWithPercentage: String { Formatter.withPercentage.string(for: (self / 100)).emptyIfNil }
}
