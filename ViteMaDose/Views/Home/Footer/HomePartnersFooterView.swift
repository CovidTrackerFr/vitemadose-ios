// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

final class HomePartnersFooterView: UIView {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var logo1ImageView: UIImageView!
    @IBOutlet private var logo2ImageView: UIImageView!
    @IBOutlet private var logo3ImageView: UIImageView!
    @IBOutlet private var logo4ImageView: UIImageView!
    @IBOutlet private var logoImageView5: UIImageView!
    @IBOutlet private var logo6ImageView: UIImageView!
    @IBOutlet private var logo7ImageView: UIImageView!
    @IBOutlet private var logo8ImageView: UIImageView!
    @IBOutlet private var logo9ImageView: UIImageView!

    private lazy var allLogos: [UIImageView] = [
        logo1ImageView,
        logo2ImageView,
        logo3ImageView,
        logo4ImageView,
        logoImageView5,
        logo6ImageView,
        logo7ImageView,
        logo8ImageView,
        logo9ImageView
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray

        titleLabel.text = Localization.Home.partners
        titleLabel.font = UIFont.accessibleFootnoteLight
        titleLabel.textColor = .secondaryLabel
        titleLabel.isAccessibilityElement = false
        titleLabel.adjustsFontForContentSizeCategory = true

        for logoImageView in allLogos {
            logoImageView.image = logoImageView.image?.tint(with: .systemGray)
        }
    }
}
