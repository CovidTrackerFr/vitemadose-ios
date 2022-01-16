// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

// MARK: - Credit

struct Credit: Codable {
    let nom: String?
    let pseudo: String?
    let photo: String?
    let site_web: String?
    let job: String?
    let localisation: String?
    let company: String?
    let teams: [String]?
    let links: [CreditLink]?

    var shownName: String {
        nom ?? pseudo ?? Localization.Credits.noName
    }

    var shownRole: String {
        teams?.joined(separator: .commaWithSpace) ?? Localization.Credits.noRole
    }
}

// MARK: - Credit Link

struct CreditLink: Codable {
    let site: String?
    let url: String?
}

extension CreditLink: Hashable {}

// MARK: - Credits

struct Credits: Codable {
    let contributors: [Credit]?
}
