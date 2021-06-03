//
//  VaccinationCentresTitleCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
//

import UIKit

final class CentresTitleCell: HomeTitleCell {
    private enum Constant {
        static let titleFont: UIFont = .accessibleTitle1Bold
        static let titleColor: UIColor = .label
    }
}

extension CentresTitleCell {

    static func mainTitleAttributedText(
        withAppointmentsCount appointmentsCount: Int,
        andSearchResult searchResult: LocationSearchResult?
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]

        let searchResultName = (searchResult?.formattedName).emptyIfNil

        guard appointmentsCount > 0 else {
            let title = NSMutableAttributedString(
                string: Localization.Locations.no_results.format(searchResultName),
                attributes: attributes
            )
            title.setColorForText(textForAttribute: searchResultName, withColor: .mandy)
            return title
        }

        let isDepartment = searchResult?.coordinates == nil

        let appointmentsCountString = Localization.Locations.appointments.format(appointmentsCount)
        let titleString: String
        if isDepartment {
            titleString  = Localization.Locations.MainTitle.title_department.format(appointmentsCount, searchResultName)
        } else {
            titleString  = Localization.Locations.MainTitle.title_city.format(appointmentsCount, searchResultName)
        }

        let title = NSMutableAttributedString(
            string: titleString,
            attributes: attributes
        )
        title.setColorForText(textForAttribute: appointmentsCountString, withColor: .mandy)
        title.setColorForText(textForAttribute: searchResultName, withColor: .royalBlue)

        return title
    }

    static var centresListTitle: NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]
        return NSMutableAttributedString(string: Localization.Locations.list_title, attributes: attributes)
    }

    static var followedCentresListTitle: NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]
        return NSMutableAttributedString(string: Localization.Locations.followed_list_title, attributes: attributes)
    }

}
