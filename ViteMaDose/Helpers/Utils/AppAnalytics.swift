//
//  Logger.swift
//  ViteMaDose
//
//  Created by Paul on 15/04/2021.
//

import Foundation
import FirebaseAnalytics

struct AppAnalytics {

    enum ScreenName: String {
        case home = "home"
        case searchResults = "search_results"
        case departmentSelect = "departement_select"
    }

    static func logScreen(_ screenName: ScreenName, screenClass: String) {
        Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [
                AnalyticsParameterScreenName: screenName.rawValue,
                AnalyticsParameterScreenClass: screenClass,
            ])
    }

    static func didTapSearchBar() {
        Analytics.logEvent("search_by_departement", parameters: [:])
    }

    static func didSelectCounty(_ county: County) {
        Analytics.logEvent("county_selected", parameters: [
            "codeDepartement": (county.codeDepartement?.lowercased() ?? "") as NSString
        ])
    }

    static func didSelectVaccinationCentre(_ vaccinationCentre: VaccinationCentre) {
        let eventName = (vaccinationCentre.appointmentCount ?? 0) > 0 ? "rdv_click" : "rdv_verify"
        let county = vaccinationCentre.departement?.lowercased() ?? ""
        let name = vaccinationCentre.nom?.lowercased() ?? ""
        let type = vaccinationCentre.type?.lowercased() ?? ""
        let platform = vaccinationCentre.plateforme?.lowercased() ?? ""
        let vaccine = vaccinationCentre.vaccineType?.joined(separator: ",").lowercased() ?? ""

        Analytics.logEvent(eventName, parameters: [
            "rdv_departement": county,
            "rdv_name": name,
            "rdv_location_type": type,
            "rdv_platform": platform,
            "rdv_vaccine":vaccine,
        ])
    }

}
