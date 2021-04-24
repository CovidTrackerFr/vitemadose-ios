//
//  String+Localization.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 24/04/2021.
//
// swiftlint:disable identifier_name

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }

    func localized(_ args: [String]) -> String {
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
}
