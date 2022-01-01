// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import UIKit

final class HomeFollowedCentresCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var cellContainerView: UIView!
    @IBOutlet private var iconContainerView: UIView!

    private enum Constant {
        static let codeTextColor: UIColor = .white
        static let nameTextColor: UIColor = .label
        static let codeBackgroundColor: UIColor = .royalBlue
        static let cellBackgroundColor: UIColor = .tertiarySystemBackground
        static let titleFont: UIFont = .accessibleBodyBold
        static let labelsFont: UIFont = .rounded(ofSize: 18, weight: .bold)
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure() {
        contentView.backgroundColor = .athensGray

        iconContainerView.backgroundColor = .mandy
        cellContainerView.backgroundColor = .tertiarySystemBackground

        iconContainerView.setCornerRadius(15)
        cellContainerView.setCornerRadius(15)

        titleLabel.text = "Mes centres suivis"
        titleLabel.textColor = .label
        titleLabel.font = Constant.titleFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
