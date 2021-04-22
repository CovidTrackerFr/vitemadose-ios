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

        static let titleFirstPartText = "we_found".localized()
        static let titleSecondPartText = "shots".localized()
        static let titleThirdText = "for_the_area".localized()
        static let titleNoDoseText = "no_shots_found".localized()
        static let subtitleText = "locations_list".localized()
    }
}

extension CentresTitleCell {

    static func mainTitleAttributedText(
        withDoses dosesCount: Int,
        andCountyName countyName: String
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont,
        ]

        guard dosesCount > 0 else {
            let title = NSMutableAttributedString(
                string:"\(Constant.titleNoDoseText) \(countyName)",
                attributes: attributes
            )
            title.setColorForText(textForAttribute: countyName, withColor: .mandy)
            return title
        }

        let dosesCountString = "\(String(dosesCount)) \(Constant.titleSecondPartText)"
        let titleString = "\(Constant.titleFirstPartText) \(dosesCountString) \(Constant.titleThirdText) \(countyName)"
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
            NSAttributedString.Key.font: Constant.titleFont,
        ]
        return NSMutableAttributedString(string: Constant.subtitleText, attributes: attributes)
    }

}
