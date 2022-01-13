// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

public enum VaccineType: String, Codable {
    case arnm = "ARNm"
    case novavax = "Novavax"
    case janssen = "Janssen"
    case pfizerBioNTech = "Pfizer-BioNTech"
    case moderna = "Moderna"
}

extension VaccineType {

    /// Content which can be vocalized in french with the expected prosody
    var vocalizable: String { // (ﾉಥ益ಥ）ﾉ﻿ ┻━┻  (yes, it works)
        switch self {
        case .arnm:
            return "a-r-n-m"
        case .novavax:
            return "Novavax"
        case .janssen:
            return "géne saine"
        case .pfizerBioNTech:
            return "p'faille zeure bio haine teck"
        case .moderna:
            return "Moderna"
        }
    }
}
