// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

/// Available filtering options for centres list
public enum CentresListFilterOption: Int, CaseIterable {

    /// Filter nothing, keep all centres
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
    /// Vaccine type "Novavax"
    case vaccineTypeNovavax

    public init?(rawValue: Int) {
        if let value = CentresListFilterOption.allCases.first(where: { $0.rawValue == rawValue }) {
            self = value
        } else {
            return nil
        }
    }
}
