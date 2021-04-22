//
//  LocalizedString.swift
//  ViteMaDose
//
//  Created by PlugN on 22/04/2021.
//

import Foundation

struct LocalizedString {
    
    
    // Unchanging strings
    static let title_text = "title_text".localized()
    static let easily = "easily".localized()
    static let quickly = "quickly".localized()
    static let last_stats = "last_stats".localized()
    static let found_locations_country = "found_locations_country".localized()
    static let location = "location".localized()
    static let locations = "locations".localized()
    static let available_slots = "available_slots".localized()
    static let percentage_available = "percentage_available".localized()
    static let open_map_locations_space = "open_map_locations_space".localized()
    static let select_area = "select_area".localized()
    static let find_appointment_with = "find_appointment_with".localized()
    static let select_your_area = "select_your_area".localized()
    static let area = "area".localized()
    static let we_found = "we_found".localized()
    static let shots = "shots".localized()
    static let for_the_area = "for_the_area".localized()
    static let no_shots_found = "no_shots_found".localized()
    static let locations_list = "locations_list".localized()
    static let found_locations = "found_locations".localized()
    static let found_locaion = "found_locaion".localized()
    static let no_appointments = "no_appointments".localized()
    static let unavailable_date = "unavailable_date".localized()
    static let open_route = "open_route".localized()
    static let cancel = "cancel".localized()
    static let recent_search = "recent_search".localized()
    static let book_appointment_space = "book_appointment_space".localized()
    static let check_location_space = "check_location_space".localized()
    static let location_name_unavailable = "location_name_unavailable".localized()
    static let address_unavailable = "address_unavailable".localized()
    static let unexpected_error = "unexpected_error".localized()
    static let retry = "retry".localized()
    
    
    // Variable strings
    static func availablilties(quantity: String) -> String {
        return "availablilties".localized().format([quantity])
    }
    static func percentage(quantity: String) -> String {
        return "percentage".localized().format([quantity])
    }
    static func date_string(date: String, time: String) -> String {
        return "date_string".localized().format([date, time])
    }
    static func x_shot_space(quantity: String) -> String {
        return "x_shot_space".localized().format([quantity])
    }
    static func x_shots_space(quantity: String) -> String {
        return "x_shots_space".localized().format([quantity])
    }
    static func with_appointments(quantity: String) -> String {
        return "with_appointments".localized().format([quantity])
    }
    static func total_locations(quantity: String) -> String {
        "total_locations".localized().format([quantity])
    }
    static func last_updated(date: String, time: String) -> String {
        return "last_updated".localized().format([date, time])
    }
    
    
}
