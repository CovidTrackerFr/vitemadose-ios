// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

public enum CentresListSortOption: Equatable {
    case closest
    case fastest
    case thirdDose

    init(_ value: Int) {
        switch value {
        case 0:
            self = .closest
        case 1:
            self = .fastest
        case 2:
            self = .thirdDose
        default:
            assertionFailure("Value should either be 0, 1 or 2")
            self = .closest
        }
    }

    var index: Int {
        switch self {
        case .closest:
            return 0
        case .fastest:
            return 1
        case .thirdDose:
            return 2
        }
    }
}
