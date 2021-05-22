//
//  CreditHeaderView.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import UIKit

class CreditHeaderView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    private enum Constant {
        static let highlightedTextColor1 = UIColor.royalBlue
        static let highlightedTextColor2 = UIColor.mandy
        static let titleFont = UIFont.rounded(ofSize: 24, weight: .bold)
        static let descriptionFont = UIFont.rounded(ofSize: 18, weight: .regular)
        static let searchBarFont = UIFont.rounded(ofSize: 16, weight: .medium)
        static let searchBarViewCornerRadius: CGFloat = 10.0
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