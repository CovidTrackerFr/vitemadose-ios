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
}

// MARK: - Credits

typealias Credits = [Credit]
