//
//  VaccinationCentre.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

// MARK: - VaccinationCentre

struct VaccinationCentre: Codable {
    let departement: String?
    let nom: String?
    let url: String?
    let plateforme: String?
    let prochainRdv: String?
    
    enum CodingKeys: String, CodingKey {
        case departement = "departement"
        case nom = "nom"
        case url = "url"
        case plateforme = "plateforme"
        case prochainRdv = "prochain_rdv"
    }
}

// MARK: - VaccinationCentres

struct VaccinationCentres: Codable {
    let lastUpdated: String?
    let centresDisponibles: [VaccinationCentre]
    let centresIndisponibles: [VaccinationCentre]
    
    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case centresDisponibles = "centres_disponibles"
        case centresIndisponibles = "centres_indisponibles"
    }
}
