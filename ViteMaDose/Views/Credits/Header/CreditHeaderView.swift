//
//  CreditHeaderView.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import UIKit

class CreditHeaderView: UIView {
    @IBOutlet var titleLabel: UILabel!

    private enum Constant {
        static let titleText = "Notre magnifique équipe"
        static let highlightedText = "équipe"
        static let highlightedTextColor = UIColor.mandy
        static let titleFont = UIFont.rounded(ofSize: 24, weight: .bold)
        static let searchBarFont = UIFont.rounded(ofSize: 16, weight: .medium)
        static let searchBarViewCornerRadius: CGFloat = 10.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        configureTitle()
    }

    private func configureTitle() {
        let attributedText = NSMutableAttributedString(
            string: Constant.titleText,
            attributes: [
                NSAttributedString.Key.font: Constant.titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )
        attributedText.setColorForText(
            textForAttribute: Constant.highlightedText,
            withColor: Constant.highlightedTextColor
        )
        titleLabel.attributedText = attributedText
    }
}
