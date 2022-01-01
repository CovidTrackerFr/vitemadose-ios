//
//  Credit.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import Foundation

// MARK: - Credit

struct Credit: Codable {
    let id: String?
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
        nom ?? pseudo ?? id ?? Localization.Credits.noName
    }

    var shownRole: String {
        teams?.joined(separator: ", ") ?? Localization.Credits.noRole
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
