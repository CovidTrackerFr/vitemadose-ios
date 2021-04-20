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
        static let titleText = "Contributeurs"
        static let descriptionText = "ViteMaDose est un projet open source, construit par l'ensemble de ses généreux contributeurs :"
        static let highlightedText1 = "open source"
        static let highlightedText2 = "généreux contributeurs"
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
            string: Constant.titleText,
            attributes: [
                NSAttributedString.Key.font: Constant.titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )
        titleLabel.attributedText = attributedText
    }
    
    private func configureDescription() {
        let attributedText = NSMutableAttributedString(
            string: Constant.descriptionText,
            attributes: [
                NSAttributedString.Key.font: Constant.descriptionFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )
        attributedText.setColorForText(
            textForAttribute: Constant.highlightedText1,
            withColor: Constant.highlightedTextColor1
        )
        attributedText.setColorForText(
            textForAttribute: Constant.highlightedText2,
            withColor: Constant.highlightedTextColor2
        )
        descriptionLabel.attributedText = attributedText
    }
}
