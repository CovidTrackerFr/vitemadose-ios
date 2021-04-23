//
//  HomeTitleCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 17/04/2021.
//

import UIKit

protocol HomeTitleCellViewDataProvider {
    var titleText: NSMutableAttributedString { get }
    var subTitleText: NSMutableAttributedString? { get }
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
}

struct HomeTitleCellViewData: HomeTitleCellViewDataProvider, Hashable {
    let titleText: NSMutableAttributedString
    let subTitleText: NSMutableAttributedString?
    let topMargin: CGFloat
    let bottomMargin: CGFloat

    init(
        titleText: NSMutableAttributedString,
        subTitleText: NSMutableAttributedString? = nil,
        topMargin: CGFloat = 10,
        bottomMargin: CGFloat = 10
    ) {
        self.titleText = titleText
        self.subTitleText = subTitleText
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
    }
}

class HomeTitleCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!

    func configure(with viewData: HomeTitleCellViewDataProvider) {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        titleLabel?.backgroundColor = .clear
        descriptionLabel?.backgroundColor = .clear

        titleLabel?.attributedText = viewData.titleText
        descriptionLabel?.attributedText = viewData.subTitleText

        titleLabel?.numberOfLines = 0
        descriptionLabel?.numberOfLines = 0

        topConstraint.constant = viewData.topMargin
        bottomConstraint.constant = viewData.bottomMargin
    }
}

extension HomeTitleCell {
    static var mainTitleAttributedText: NSMutableAttributedString {
        let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)

        let attributedText = NSMutableAttributedString(
            string: LocalizedString.home.title.title,
            attributes: [
                NSAttributedString.Key.font: titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )

        attributedText.setColorForText(
            textForAttribute: LocalizedString.home.title.first_highlighted_text,
            withColor: .royalBlue
        )
        attributedText.setColorForText(
            textForAttribute: LocalizedString.home.title.second_highlighted_text,
            withColor: .mandy
        )

        return attributedText
    }

    static var lastStatsAttributedText: NSMutableAttributedString {
        let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)

        return NSMutableAttributedString(
            string: LocalizedString.home.stats.last_stats,
            attributes: [
                NSAttributedString.Key.font: titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )
    }
}
