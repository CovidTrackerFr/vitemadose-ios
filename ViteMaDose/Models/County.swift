//
//  County.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

// MARK: - County

struct County: Codable {
	let codeDepartement: String?
	let nomDepartement: String?
	let codeRegion: Int?
	let nomRegion: String?

	enum CodingKeys: String, CodingKey {
		case codeDepartement = "code_departement"
		case nomDepartement = "nom_departement"
		case codeRegion = "code_region"
		case nomRegion = "nom_region"
	}
}

// MARK: - Counties

typealias Counties = [County]
