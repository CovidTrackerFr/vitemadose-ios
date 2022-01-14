// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

// MARK: - Centre Action Cell View Data Provider

public typealias ButtonAction = () -> Void

protocol CentreActionCellViewDataProvider {
    var titleText: NSMutableAttributedString { get }
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
}

// MARK: - Centre Action Cell View Data

public struct CentreActionCellViewData: CentreActionCellViewDataProvider, Hashable {

    let titleText: NSMutableAttributedString
    let topMargin: CGFloat
    let bottomMargin: CGFloat

    init(titleText: NSMutableAttributedString, topMargin: CGFloat = 10, bottomMargin: CGFloat = 10) {
        self.titleText = titleText
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
    }
}

// MARK: - Centre Action Celll

class CentreActionCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!

    var actionButtonTapHandler: (() -> Void)?

    private enum Constant {
        static let titleFont: UIFont = .accessibleTitle1Bold
        static let titleColor: UIColor = .label
    }

    func configure(with viewData: CentreActionCellViewDataProvider) {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        titleLabel.backgroundColor = .clear
        titleLabel.attributedText = viewData.titleText
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        topConstraint.constant = viewData.topMargin
        bottomConstraint.constant = viewData.bottomMargin

        actionButton.addTarget(
            self,
            action: #selector(didTapActionButton),
            for: .touchUpInside
        )
        actionButton.accessibilityLabel = Localization.A11y.VoiceOver.Actions.filter_button_label
        actionButton.accessibilityHint = Localization.A11y.VoiceOver.Actions.filter_button_hint
        let actionButtonIconName = UIDevice.current.isUnderiOS15 ? "list.dash" : "line.3.horizontal.decrease.circle.fill"
        actionButton.setImage(UIImage(systemName: actionButtonIconName), for: .normal)
    }

    @objc private func didTapActionButton() {
        actionButtonTapHandler?()
    }
}

extension CentreActionCell {

    static var centresListTitle: NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]
        return NSMutableAttributedString(string: Localization.Locations.list_title, attributes: attributes)
    }
}
