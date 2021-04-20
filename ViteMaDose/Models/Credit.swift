//
//  Credit.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import Foundation

// MARK: - Credit

struct Credit: Codable {
    let nom: String?
    let image: String?
    let role: String?
}

// MARK: - CreditSection

struct CreditSection: Codable {
    let section: String?
    let users: [Credit]?
}

// MARK: - Credits

typealias Credits = [CreditSection]

// MARK: - Credit Store (TEMP)

struct CreditStore {
    static let store: Credits = [
        CreditSection(section: "Chef d'équipe", users: [
            Credit(nom: "Guillaume Rozier", image: "https://github.com/rozierguillaume.png", role: ""),
        ]),
        CreditSection(section: "Team iOS", users: [
            Credit(nom: "Victor Sarda", image: "https://github.com/victor-sarda.png", role: ""),
            Credit(nom: "Paul Jeannot", image: "https://github.com/pauljeannot.png", role: ""),
            Credit(nom: "Nathan Fallet", image: "https://github.com/NathanFallet.png", role: ""),
        ]),
        CreditSection(section: "Team Android", users: [
            Credit(nom: "Michel Gauzins", image: "https://github.com/michgauz.png", role: ""),
            Credit(nom: "JB Dumoulin", image: "https://github.com/dumoulinjb.png", role: ""),
        ]),
    ]
}
