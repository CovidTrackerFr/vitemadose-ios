//
//  VaccinationCentresTitleCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
//

import UIKit

class CentresTitleCell: HomeTitleCell {
    private enum Constant {
        static let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)
        static let titleColor: UIColor = .label

        static let highlightedDosesTextColor: UIColor = .systemGreen
        static let highlightedCountyTextColor: UIColor = .mandy
    }
}

extension CentresTitleCell {

    static func mainTitleAttributedText(
        withDoses dosesCount: Int,
        andCountyName countyName: String
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]

        guard dosesCount > 0 else {
            let title = NSMutableAttributedString(
                string: Localization.LocationsList.no_results.format(countyName),
                attributes: attributes
            )
            title.setColorForText(textForAttribute: countyName, withColor: .mandy)
            return title
        }

        let dosesCountString = Localization.LocationsList.doses.format(dosesCount)
        let titleString = Localization.LocationsList.MainTitle.title.format(dosesCount, countyName)
        let title = NSMutableAttributedString(
            string: titleString,
            attributes: attributes
        )
        title.setColorForText(textForAttribute: dosesCountString, withColor: .mandy)
        title.setColorForText(textForAttribute: countyName, withColor: .royalBlue)

        return title
    }

    static var centresListTitle: NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]
        return NSMutableAttributedString(string: Localization.LocationsList.list_title, attributes: attributes)
    }

}
