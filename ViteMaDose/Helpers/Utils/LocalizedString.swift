//
//  LocalizedString.swift
//  ViteMaDose
//
//  Created by PlugN on 22/04/2021.
//

import Foundation

enum LocalizedString {
    
    enum home {
        
        static let partners = "home.partners".localized()
        static let recent_search = "home.recent_search".localized()
        
        enum title {
            
            static let title = "home.title.title".localized()
            static let first_highlighted_text = "home.title.first_highlighted_text".localized()
            static let second_highlighted_text = "home.title.second_highlighted_text".localized()
            
        }
        
        enum stats {
            
            static let last_stats = "home.stats.last_stats".localized()
            static let all_locations = "home.stats.all_locations".localized()
            static let all_availabilities = "home.stats.all_availabilities".localized()
            static let percentage = "home.stats.percentage".localized()
            static let open_map = "home.stats.open_map".localized()
            
            static func available_locations(_ plural: String) -> String {
                return "home.stats.available_locations".localized().format([plural])
            }
        }
        
    }
    
    enum global {
        
        static let location = "global.location".localized()
        static let locations = "global.locations".localized()
        
        static func percentage(_ quantity: Int) -> String {
            return "global.percentage".localized().format([String(quantity)])
        }
        
    }
    
    
    enum country_selection {
        
        enum title {
            
            static let title = "country_selection.title.title".localized()
            static let highlighted_text = "country_selection.title.highlighted_text".localized()
            
        }
        
    }
    
    
    
    enum vaccination_locations_list {
        
        static let no_results = "vaccination_locations_list.no_results".localized()
        static let list_title = "vaccination_locations_list.list_title".localized()
        static let found_locations = "vaccination_locations_list.found_locations".localized()
        static let found_location = "vaccination_locations_list.found_location".localized()
        static let no_appointments = "vaccination_locations_list.no_appointments".localized()
        static let date_unavailable = "vaccination_locations_list.date_unavailable".localized()
        static let open_route = "vaccination_locations_list.open_route".localized()
        static let book_button = "vaccination_locations_list.book_button".localized()
        static let verify_button = "vaccination_locations_list.verify_button".localized()
        static let location_name_unavailable = "vaccination_locations_list.location_name_unavailable".localized()
        static let address_unavailable = "vaccination_locations_list.address_unavailable".localized()
        static let cancel_button = "vaccination_locations_list.cancel_button".localized()
        
        
        static func date(date: String, time: String) -> String {
            return "vaccination_locations_list.date".localized().format([date, time])
        }
        static func dose(_ quantity: Int) -> String {
            return "vaccination_locations_list.dose".localized().format([String(quantity)])
        }
        static func doses(_ quantity: Int) -> String {
            return "vaccination_locations_list.doses".localized().format([String(quantity)])
        }
        static func available_locations(_ plural: String) -> String {
            return "vaccination_locations_list.available_locations".localized().format([plural])
        }
        static func all_locations(_ plural: String) -> String {
            "vaccination_locations_list.all_locations".localized().format([plural])
        }
        static func last_update(date: String, time: String) -> String {
            return "vaccination_locations_list.last_update".localized().format([date, time])
        }
        static func title(quantity: String, area: String) -> String {
            "vaccination_locations_list.title".localized().format([quantity, area])
        }
        
    }
    
    enum generic_error {
        
        static let cancel_button = "generic_error.cancel_button".localized()
        static let title = "generic_error.title".localized()
        static let retry_button = "generic_error.retry_button".localized()
        static let default_message = "generic_error.default_message".localized()
        
    }
    
}
