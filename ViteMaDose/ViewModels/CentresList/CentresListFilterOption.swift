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
    /// Keep only centres with kids first doses
    case kidsFirstDoses

    /// Vaccine type "Moderna"
    case vaccineTypeModerna
    /// Vaccine type "Pfizer"
    case vaccineTypePfizer
    /// Vaccine type "ARN-m"
    case vaccineTypeARNm
    /// Vaccine type "Janssen"
    case vaccineTypeJanssen

    init(_ value: Int) {
        switch value {
        case 0:
            self = .allDoses
        case 1:
            self = .kidsFirstDoses
        case 2:
            self = .vaccineTypeModerna
        case 3:
            self = .vaccineTypePfizer
        case 4:
            self = .vaccineTypeARNm
        case 5:
            self = .vaccineTypeJanssen
        default:
            self = .allDoses
        }
    }

    var index: Int {
        switch self {
        case .allDoses:
            return 0
        case .kidsFirstDoses:
            return 1
        case .vaccineTypeModerna:
            return 2
        case .vaccineTypePfizer:
            return 3
        case .vaccineTypeARNm:
            return 4
        case .vaccineTypeJanssen:
            return 5
        }
    }
}
