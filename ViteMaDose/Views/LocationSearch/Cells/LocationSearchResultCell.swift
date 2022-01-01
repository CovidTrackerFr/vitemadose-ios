// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

protocol LocationSearchResultCellViewDataProvider {
    var name: String { get }
    var postCode: String? { get }
    var departmentCode: String? { get }
}

struct LocationSearchResultCellViewData: LocationSearchResultCellViewDataProvider, Hashable {
    let name: String
    let postCode: String?
    let departmentCode: String?
}

class LocationSearchResultCell: UITableViewCell {
    @IBOutlet private var codeLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var cellContainerView: UIView!
    @IBOutlet private var codeContainerView: UIView!

    private enum Constant {
        static let codeTextColor: UIColor = .white
        static let nameTextColor: UIColor = .label
        static let codeBackgroundColor: UIColor = .royalBlue
        static let cellBackgroundColor: UIColor = .tertiarySystemBackground
        static let labelsFont: UIFont = .accessibleBodyBold
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewData: LocationSearchResultCellViewDataProvider) {
        contentView.backgroundColor = .athensGray

        codeContainerView.backgroundColor = Constant.codeBackgroundColor
        cellContainerView.backgroundColor = Constant.cellBackgroundColor

        codeContainerView.setCornerRadius(Constant.viewsCornerRadius)
        cellContainerView.setCornerRadius(Constant.viewsCornerRadius)

        codeLabel.text = viewData.departmentCode
        nameLabel.text = viewData.name

        codeLabel.textColor = Constant.codeTextColor
        nameLabel.textColor = Constant.nameTextColor

        codeLabel.font = Constant.labelsFont
        nameLabel.font = Constant.labelsFont

        codeLabel.adjustsFontForContentSizeCategory = true
        nameLabel.adjustsFontForContentSizeCategory = true

        accessibilityTraits = .button
        accessibilityLabel = Localization.A11y.VoiceOver.Locations.see_places.format(viewData.name)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        codeLabel.text = nil
    }
}
