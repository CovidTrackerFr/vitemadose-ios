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
