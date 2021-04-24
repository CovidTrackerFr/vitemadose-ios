//
//  String+Localization.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 24/04/2021.
//
// swiftlint:disable identifier_name

import Foundation

extension String {
    static var space = " "
    static var commaWithSpace = ", "

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func format(_ args: CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }

    func format(_ args: [String]) -> String {
        return String(format: self, locale: .current, arguments: args)
    }
}

enum Localization {
    enum Home {
        static let select_county = "home.select_county".localized
        static let recent_search = "home.recent_search".localized
        static let last_stats = "home.last_stats".localized
        static let open_map = "home.open_map".localized
        static let partners = "home.partners".localized

        enum MainTitle {
            static let title = "home.main_title".localized
            static let first_highlighted_text = "home.main_title.first_highlighted_text".localized
            static let second_highlighted_text = "home.main_title.second_highlighted_text".localized
        }

        enum Stats {
            static let all_locations = "home.stats.all_locations".localized
            static let all_availabilities = "home.stats.all_availabilities".localized
            static let locations_with_availabilities = "home.stats.locations_with_availabilities".localized
            static let available_locations_percentage = "home.stats.available_locations_percentage".localized
        }
    }

    enum CountySelection {
        enum MainTitle {
            static let title = "county_selection.main_title".localized
            static let highlighted_text = "county_selection.main_title.highlighted_text".localized
        }
    }

    enum LocationsList {
        static let list_title = "locations-list.list_title".localized
        static let no_results = "locations.no_results".localized
        static let available_locations = "locations-list.available_locations".localized
        static let all_locations = "locations-list.all_locations".localized
        static let doses = "locations-list.doses".localized

        enum MainTitle {
            static let title = "locations-list.main_title".localized
        }
    }

    enum Location {
        static let date = "location.date".localized
        static let book_button = "location.book_button".localized
        static let verify_button = "location.verify_button".localized
        static let last_update = "location.last_update".localized
        static let no_appointment = "location.no_appointment".localized
        static let open_route = "location.open_route".localized
        static let unavailable_date = "location.unavailable_date".localized
        static let unavailable_name = "location.unavailable_name".localized
        static let unavailable_address = "location.unavailable_address".localized
    }

    enum Error {
        enum Generic {
            static let title = "error.generic.title".localized
            static let retry_button = "error.generic.retry_button".localized
            static let cancel_button = "error.generic.cancel_button".localized
            static let default_message = "error.generic.default_message".localized
        }
    }
}
