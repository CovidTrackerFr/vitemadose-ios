//
//  LocalizedString.swift
//  ViteMaDose
//
//  Created by PlugN on 22/04/2021.
//

import Foundation

enum LocalizedString {

    enum Home {

        static let partners = "home.partners".localized()
        static let recentSearch = "home.recent_search".localized()

        enum Title {

            static let title = "home.title.title".localized()
            static let firstHighlightedText = "home.title.first_highlighted_text".localized()
            static let secondHighlightedText = "home.title.second_highlighted_text".localized()

        }

        enum Stats {

            static let lastStats = "home.stats.last_stats".localized()
            static let allLocations = "home.stats.all_locations".localized()
            static let allAvailabilities = "home.stats.all_availabilities".localized()
            static let percentage = "home.stats.percentage".localized()
            static let openMap = "home.stats.open_map".localized()

            static func availableLocations(_ plural: String) -> String {
                return "home.stats.available_locations".localized().format([plural])
            }
        }

    }

    enum Global {

        static let location = "global.location".localized()
        static let locations = "global.locations".localized()

        static func percentage(_ quantity: Int) -> String {
            return "global.percentage".localized().format([String(quantity)])
        }

    }

    enum CountrySelection {

        enum Title {

            static let title = "country_selection.title.title".localized()
            static let highlightedText = "country_selection.title.highlighted_text".localized()

        }

    }

    enum VaccinationLocationsList {

        static let noResults = "vaccination_locations_list.no_results".localized()
        static let listTitle = "vaccination_locations_list.list_title".localized()
        static let foundLocations = "vaccination_locations_list.found_locations".localized()
        static let foundLocation = "vaccination_locations_list.found_location".localized()
        static let noAppointments = "vaccination_locations_list.no_appointments".localized()
        static let dateUnavailable = "vaccination_locations_list.date_unavailable".localized()
        static let openRoute = "vaccination_locations_list.open_route".localized()
        static let bookButton = "vaccination_locations_list.book_button".localized()
        static let verifyButton = "vaccination_locations_list.verify_button".localized()
        static let locationNameUnavailable = "vaccination_locations_list.location_name_unavailable".localized()
        static let addressUnavailable = "vaccination_locations_list.address_unavailable".localized()
        static let cancelButton = "vaccination_locations_list.cancel_button".localized()

        static func date(date: String, time: String) -> String {
            return "vaccination_locations_list.date".localized().format([date, time])
        }
        static func dose(_ quantity: Int) -> String {
            return "vaccination_locations_list.dose".localized().format([String(quantity)])
        }
        static func doses(_ quantity: Int) -> String {
            return "vaccination_locations_list.doses".localized().format([String(quantity)])
        }
        static func availableLocations(_ plural: String) -> String {
            return "vaccination_locations_list.available_locations".localized().format([plural])
        }
        static func allLocations(_ plural: String) -> String {
            "vaccination_locations_list.all_locations".localized().format([plural])
        }
        static func lastUpdate(date: String, time: String) -> String {
            return "vaccination_locations_list.last_update".localized().format([date, time])
        }
        static func title(quantity: String, area: String) -> String {
            "vaccination_locations_list.title".localized().format([quantity, area])
        }

    }

    enum GenericError {

        static let cancelButton = "generic_error.cancel_button".localized()
        static let title = "generic_error.title".localized()
        static let retryButton = "generic_error.retry_button".localized()
        static let defaultMessage = "generic_error.default_message".localized()

    }

}
