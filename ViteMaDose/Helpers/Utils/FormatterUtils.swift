// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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
