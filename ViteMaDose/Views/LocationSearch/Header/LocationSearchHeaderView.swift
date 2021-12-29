// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

final class LocationSearchHeaderView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private(set) weak var searchBar: UISearchBar!

    private enum Constant {
        static let highlightedTextColor = UIColor.mandy
        static let titleFont: UIFont = .accessibleTitle2Bold
        static let searchBarFont: UIFont = .accessibleCalloutMedium
        static let searchBarViewCornerRadius: CGFloat = 10.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        searchBar.placeholder = Localization.LocationSearch.search_placeholder
        searchBar.isAccessibilityElement = true
        searchBar.accessibilityTraits = .searchField
        searchBar.accessibilityLabel = Localization.A11y.VoiceOver.Locations.search
        configureTitle()
    }

    private func configureTitle() {
        let attributedText = NSMutableAttributedString(
            string: Localization.LocationSearch.MainTitle.title,
            attributes: [
                NSAttributedString.Key.font: Constant.titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
        )
        attributedText.setColorForText(
            textForAttribute: Localization.LocationSearch.MainTitle.highlighted_text,
            withColor: Constant.highlightedTextColor
        )
        titleLabel.attributedText = attributedText
    }
}
