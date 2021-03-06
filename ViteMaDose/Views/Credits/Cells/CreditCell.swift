// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit
import Kingfisher

// MARK: - Credit Cell View Data Provider

protocol CreditCellViewDataProvider {
    var creditName: String { get }
    var creditRole: AccessibilityString { get }
    var creditLink: URL? { get }
    var creditImage: String? { get }
}

// MARK: - Credit Ceell View Data

struct CreditCellViewData: CreditCellViewDataProvider, Hashable {
    var creditName: String
    var creditRole: AccessibilityString
    var creditLink: URL?
    var creditImage: String?
}

// MARK: - Credit Cell
class CreditCell: UITableViewCell {
    @IBOutlet private var creditImageView: UIImageView!
    @IBOutlet private var creditNameLabel: UILabel!
    @IBOutlet private var creditRoleLabel: UILabel!
    @IBOutlet private var creditLinkButton: UIButton!
    @IBOutlet private var creditContainerView: UIView!

    private var buttonURL: URL?
    private weak var delegate: CreditViewModelDelegate?

    @IBAction func creditLinkButtonClicked(_ sender: Any) {
        if let buttonURL = buttonURL {
            delegate?.openURL(url: buttonURL)
        }
    }

    private enum Constant {
        static let creditNameTextColor: UIColor = .label
        static let creditImageBackgroundColor: UIColor = .royalBlue
        static let cellBackgrounColor: UIColor = .tertiarySystemBackground
        static let labelMainFont: UIFont = .accessibleCalloutBold
        static let labelSecondFont: UIFont = .accessibleSubheadMedium
        static let buttonColor: UIColor = .royalBlue
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewData: CreditCellViewDataProvider, delegate: CreditViewModelDelegate?) {
        self.buttonURL = viewData.creditLink
        self.delegate = delegate

        contentView.backgroundColor = .athensGray

        creditImageView.backgroundColor = Constant.creditImageBackgroundColor
        creditContainerView.backgroundColor = Constant.cellBackgrounColor

        creditImageView.setCornerRadius(Constant.viewsCornerRadius)
        creditContainerView.setCornerRadius(Constant.viewsCornerRadius)

        if let imageURL = URL(string: viewData.creditImage.emptyIfNil) {
            creditImageView.kf.setImage(with: imageURL)
        }
        creditNameLabel.text = viewData.creditName

        // Need to be refactored: if too big a11y sizes, diplay is dirty (sometimes role or name)
        if UIApplication.shared.preferredContentSizeCategory.isAccessibleLargeTextSize {
            creditRoleLabel.isHidden = true
        } else {
            creditRoleLabel.text = viewData.creditRole.rawValue
            creditRoleLabel.accessibilityLabel = viewData.creditRole.vocalizedValue
        }

        if let url = buttonURL, url.isValid {
            creditLinkButton.isHidden = false
            creditLinkButton.accessibilityLabel = Localization.A11y.VoiceOver.Credits.credit_button_label
            creditLinkButton.accessibilityHint = Localization.A11y.VoiceOver.Credits.credit_button_hint
        } else {
            creditLinkButton.isHidden = true
        }

        creditNameLabel.textColor = Constant.creditNameTextColor
        creditRoleLabel.textColor = Constant.creditNameTextColor
        creditLinkButton.tintColor = Constant.buttonColor

        creditNameLabel.font = Constant.labelMainFont
        creditRoleLabel.font = Constant.labelSecondFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        creditNameLabel.text = nil
        creditImageView.kf.cancelDownloadTask()
        creditImageView.image = nil
    }
}
