//
//  Logger.swift
//  ViteMaDose
//
//  Created by Paul on 15/04/2021.
//

import Foundation
import FirebaseAnalytics

struct AppAnalytics {

    static func didOpenVaccinationCentresMap() {
        Analytics.logEvent("vaccination_centres_map_displayed", parameters: [:])
    }

    static func didTapSearchBar() {
        Analytics.logEvent("counties_list_displayed", parameters: [:])
    }

    static func didSelectCounty(_ county: County) {
        Analytics.logEvent("county_selected", parameters: [
            "codeDepartement": (county.codeDepartement ?? "unknown") as NSString
          ])
    }

    static func didSelectVaccinationCentre(_ vaccinationCentre: VaccinationCentre) {
        Analytics.logEvent("vaccination_centre_selected", parameters: [
            "departement": vaccinationCentre.departement ?? "",
            "nom": vaccinationCentre.nom ?? "",
            "ville": vaccinationCentre.location?.city ?? "",
            "type": vaccinationCentre.type ?? "",
            "plateforme": vaccinationCentre.plateforme ?? "",
            "vaccineType": vaccinationCentre.vaccineType?.joined(separator: "-") ?? ""
          ])
    }
}
