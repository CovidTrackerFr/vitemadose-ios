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

        static let titleFirstPartText = "Nous avons trouvé"
        static let titleSecondPartText = "doses"
        static let titleThirdText = "pour le département"
        static let titleNoDoseText = "Nous n'avons pas trouvé de doses pour le département"
        static let subtitleText = "Liste des centres"
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
