// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

public enum VaccineType: String, Codable {
    case arnm = "ARNm"
    case janssen = "Janssen"
    case pfizerBioNTech = "Pfizer-BioNTech"
    case moderna = "Moderna"
}
