// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

class CreditHeaderView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    private enum Constant {
        static let highlightedTextColor1 = UIColor.royalBlue
        static let highlightedTextColor2 = UIColor.mandy
        static let titleFont = UIFont.accessibleTitle2Bold
        static let descriptionFont = UIFont.accessibleCalloutMedium
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        configureTitle()
        configureDescription()
    }

    private func configureTitle() {
        let attributedText = NSMutableAttributedString(
            string: Localization.Credits.MainTitle.title,
            attributes: [
                NSAttributedString.Key.font: Constant.titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
        )
        titleLabel.attributedText = attributedText
    }

    private func configureDescription() {
        let attributedText = NSMutableAttributedString(
            string: Localization.Credits.MainTitle.subtitle,
            attributes: [
                NSAttributedString.Key.font: Constant.descriptionFont,
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
        )
        attributedText.setColorForText(
            textForAttribute: Localization.Credits.MainTitle.highlightedText1,
            withColor: Constant.highlightedTextColor1
        )
        attributedText.setColorForText(
            textForAttribute: Localization.Credits.MainTitle.highlightedText2,
            withColor: Constant.highlightedTextColor2
        )
        descriptionLabel.attributedText = attributedText
    }
}
