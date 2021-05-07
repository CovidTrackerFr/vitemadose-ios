//
//  Logger.swift
//  ViteMaDose
//
//  Created by Paul on 15/04/2021.
//

import Foundation
import FirebaseAnalytics

enum AppAnalytics {

    enum ScreenName: String {
        case home = "home"
        case searchResults = "search_results"
        case departmentSelect = "departement_select"
        case credit = "credit"
    }

    static func logScreen(_ screenName: ScreenName, screenClass: String) {
        Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [
                AnalyticsParameterScreenName: screenName.rawValue,
                AnalyticsParameterScreenClass: screenClass
            ])
    }

    static func didTapSearchBar() {
        Analytics.logEvent("search_by_departement", parameters: [:])
    }

    static func didSelectLocation(_ location: LocationSearchResult) {
        Analytics.logEvent("county_selected", parameters: [
            "codeDepartement": (location.departmentCode.lowercased()) as NSString
        ])
    }

    static func didSelectVaccinationCentre(_ vaccinationCentre: VaccinationCentre) {
        let eventName = (vaccinationCentre.appointmentCount ?? 0) > 0 ? "rdv_click" : "rdv_verify"
        let department = vaccinationCentre.departement?.lowercased() ?? ""
        let name = vaccinationCentre.nom?.lowercased() ?? ""
        let type = vaccinationCentre.type?.lowercased() ?? ""
        let platform = vaccinationCentre.plateforme?.lowercased() ?? ""
        let vaccine = vaccinationCentre.vaccineType?.joined(separator: ",").lowercased() ?? ""

        Analytics.logEvent(eventName, parameters: [
            "rdv_departement": department,
            "rdv_name": name,
            "rdv_location_type": type,
            "rdv_platform": platform,
            "rdv_vaccine": vaccine
        ])
    }

    static func trackSearchEvent(
        searchResult: LocationSearchResult,
        appointmentsCount: Int,
        availableCentresCount: Int,
        unAvailableCentresCount: Int,
        sortOption: CentresListSortOption
    ) {
        let eventName = searchResult.coordinates == nil ? "search_by_departement" : "search_by_commune"
        Analytics.logEvent(eventName, parameters: [
            "search_departement": "\(searchResult.departmentCode) - \(searchResult.name)",
            "search_nb_doses": appointmentsCount as NSNumber,
            "search_nb_lieu_vaccination": availableCentresCount as NSNumber,
            "search_nb_lieu_vaccination_inactive": unAvailableCentresCount as NSNumber,
            "search_filter_type": sortOption.analyticsValue
        ])
    }
}

private extension CentresListSortOption {
    var analyticsValue: String {
        switch self {
        case .closest:
            return "au plus proche"
        case .fastest:
            return "au plus tot"
        }
    }
}
