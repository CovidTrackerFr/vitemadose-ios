//
//  CountySelectionHeaderView.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 11/04/2021.
//

import UIKit

class CountySelectionHeaderView: UIView {
    @IBOutlet var titleLabel: UILabel!

    private enum Constant {
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
            string: Localization.CountySelection.MainTitle.title,
            attributes: [
                NSAttributedString.Key.font: Constant.titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
        )
        attributedText.setColorForText(
            textForAttribute: Localization.CountySelection.MainTitle.highlighted_text,
            withColor: Constant.highlightedTextColor
        )
        titleLabel.attributedText = attributedText
    }
}
