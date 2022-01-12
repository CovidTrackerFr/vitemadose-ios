// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

// swiftlint:disable identifier_name

import Foundation

enum Localization {
    enum Onboarding {
        static let next_button = "onboarding.next_button".localized
        static let done_button = "onboarding.done_button".localized

        enum WelcomePage {
            static let title = "onboarding.welcome_page.title".localized
            static let description = "onboarding.welcome_page.description".localized
        }

        enum NotificationsPage {
            static let title = "onboarding.notifications_page.title".localized
            static let description = "onboarding.notifications_page.description".localized
        }

        enum ThirdDosePage {
            static let title = "onboarding.thirddose_page.title".localized
            static let description = "onboarding.thirddose_page.description".localized
        }

        enum SettingsPage {
            static let title = "onboarding.settingspage.title".localized
            static let description = "onboarding.settingspage.description".localized
        }

        enum KidsFirstDoses {
            static let title = "onboarding.kids_first_doses.title".localized
            static let description = "onboarding.kids_first_doses.description".localized
        }

        enum VaccineTypesFiltering {
            static let title = "onboarding.vaccine_types_filtering.title".localized
            static let description = "onboarding.vaccine_types_filtering.description".localized
        }
    }

    enum Home {
        static let search_placeholder = "home.search_placeholder".localized
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

    enum LocationSearch {
        static let search_placeholder = "Commune, Code Postal, Département...".localized

        enum MainTitle {
            static let title = "location_search.main_title".localized
            static let highlighted_text = "location_search.main_title.highlighted_text".localized
        }
    }

    enum Credits {
        static let noName = "credits.no_name".localized
        static let noRole = "credits.no_role".localized

        enum MainTitle {
            static let title = "credits.main_title.title".localized
            static let subtitle = "credits.main_title.subtitle".localized
            static let highlightedText1 = "credits.main_title.highlightedText1".localized
            static let highlightedText2 = "credits.main_title.highlightedText2".localized
        }
    }

    enum Locations {
        static let list_title = "locations.list_title".localized
        static let followed_list_title = "locations.followed_list_title".localized
        static let no_results = "locations.no_results".localized
        static let available_locations = "locations.available_locations".localized
        static let all_locations = "locations.all_locations".localized
        static let appointments = "locations.appointments".localized

        enum MainTitle {
            static let title_department = "locations.main_title_department".localized
            static let title_city = "locations.main_title_city".localized
        }

        enum SortOption {
            static let closest = "locations.sort_option.closest".localized
            static let fastest = "locations.sort_option.fastest".localized
            static let third_dose = "locations.sort_option.third_dose".localized
        }

        enum Filtering {
            static let title = "location.filtering.title".localized
            static let messagge = "location.filtering.messagge".localized
            static let action_kids_doses = "location.filtering.action.kids_doses".localized
            static let action_all_doses = "location.filtering.action.all_doses".localized
            static let vaccine_type_moderna = "location.filtering.action.vaccine_type_moderna".localized
            static let vaccine_type_pfizerbiontech = "location.filtering.action.vaccine_type_pfizerbiontech".localized
            static let vaccine_type_janssen = "location.filtering.action.vaccine_type_janssen".localized
            static let vaccine_type_arnm = "location.filtering.action.vaccine_type_arnm".localized
            static let vaccine_type_novavax = "location.filtering.action.vaccine_type_novavax".localized
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
        static let start_following_title = "location.start_following_title".localized
        static let start_following_message = "location.start_following_message".localized
        static let follow_action_title = "location.follow_action_title".localized
        static let notify_button = "location.notify_button".localized
        static let follow_button = "location.follow_button".localized
        static let unfollow_action_title = "location.unfollow_action_title".localized
        static let stop_following_title = "location.stop_following_title".localized
        static let stop_following_message = "location.stop_following_message".localized
        static let stop_following_button = "location.stop_following_button".localized
    }

    enum Settings {
        static let title = "settings.title".localized

        enum WebSite {
            static let title = "settings.website.title".localized
            static let subtitle = "settings.website.subtitle".localized
        }

        enum Contributors {
            static let title = "settings.contributors.title".localized
            static let subtitle = "settings.contributors.subtitle".localized
        }

        enum Contact {
            static let title = "settings.contact.title".localized
            static let subtitle = "settings.contact.subtitle".localized
        }

        enum Twitter {
            static let title = "settings.twitter.title".localized
            static let subtitle = "settings.twitter.subtitle".localized
        }

        enum SourceCode {
            static let title = "settings.sourcecode.title".localized
            static let subtitle = "settings.sourcecode.subtitle".localized
        }

        enum System {
            static let title = "settings.system.title".localized
            static let subtitle = "settings.system.subtitle".localized
        }
    }

    enum Error {
        enum Generic {
            static let title = "error.generic.title".localized
            static let retry_button = "error.generic.retry_button".localized
            static let cancel_button = "error.generic.cancel_button".localized
            static let default_message = "error.generic.default_message".localized
        }

        enum Network {
            static let server_error = "error.network.server_error".localized
            static let offline = "error.network.offline".localized
        }
    }

    enum A11y {
        enum VoiceOver {
            enum Actions {
                static let booking_button = "a11y.voiceover.actions.booking_button".localized
                static let call_button = "a11y.voiceover.actions.call_button".localized
                static let filter_button_label = "Filtrer les centres".localized
                static let filter_button_hint = "Tappez deux fois pour filtrer les centres selon différents critères".localized
            }

            enum Details {
                static let call = "a11y.voiceover.details.call".localized
                static let from = "a11y.voiceover.details.from".localized
                static let to_use_with_platform = "a11y.voiceover.details.to_use_with_platform".localized
                static let vaccine = "a11y.voiceover.details.vaccine".localized
            }

            enum HomeScreen {
                static let display_places_on_map = "a11y.voiceover.home_screen.display_places_on_map".localized
                static let recent_searches = "a11y.voiceover.home_screen.recent_searches".localized
                static let search_field = "a11y.voiceover.home_screen.search_field".localized
                static let see_department_results = "a11y.voiceover.home_screen.see_department_results".localized
            }

            enum Locations {
                static let search = "a11y.voiceover.locations.search".localized
                static let see_places = "a11y.voiceover.locations.see_places".localized
                static let filtering_action_vaccine_type_novavax = "a11y.voiceover.locations.filtering.action.vaccine_type_novavax".localized
                static let filtering_action_vaccine_type_moderna = "a11y.voiceover.locations.filtering.action.vaccine_type_moderna".localized
                static let filtering_action_vaccine_type_pfizer = "a11y.voiceover.locations.filtering.action.vaccine_type_pfizerbiontech".localized
                static let filtering_action_vaccine_type_janssen = "a11y.voiceover.locations.filtering.action.vaccine_type_janssen".localized
                static let filtering_action_vaccine_type_arnm = "a11y.voiceover.locations.filtering.action.vaccine_type_arnm".localized
                static let filtering_action_vaccine_type_kids_doses = "a11y.voiceover.locations.filtering.action.kids_doses".localized
                static let filtering_action_vaccine_type_all_doses = "a11y.voiceover.locations.filtering.action.all_doses".localized
            }

            enum Navigation {
                static let back_button = "a11y.voiceover.navigation.back_button".localized
            }

            enum Settings {
                static let button_label = "a11y.voiceover.settings.button.label".localized
                static let button_hint = "a11y.voiceover.settings.button.hint".localized
                static let action_website = "a11y.voiceover.settings.action.website".localized
                static let action_contributors = "a11y.voiceover.settings.action.contributors".localized
                static let action_contact = "a11y.voiceover.settings.action.contact".localized
                static let action_twitter = "a11y.voiceover.settings.action.twitter".localized
                static let action_sourcecode = "a11y.voiceover.settings.action.sourcecode".localized
                static let action_advanced = "a11y.voiceover.settings.action.advanced".localized
            }

            enum Credits {
                static let credit_button_label = "a11y.voiceover.credits.credit_button.label".localized
                static let credit_button_hint = "a11y.voiceover.credits.credit_button.hint".localized
            }
        }
    }
}
