// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

/// Available filtering options for centres list
public enum CentresListFilterOption {

    /// FIlter nothing, keep all centers
    case allDoses

    /// Keep only ceentrs with kids first doses
    case kidsFirstDoses

    init(_ value: Int) {
        switch value {
        case 0:
            self = .allDoses
        case 1:
            self = .kidsFirstDoses
        default:
            assertionFailure("Value should either be 0 or 1")
            self = .allDoses
        }
    }

    var index: Int {
        switch self {
        case .allDoses:
            return 0
        case .kidsFirstDoses:
            return 1
        }
    }
}
