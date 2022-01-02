// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

protocol CentreDataDisclaimerCellViewDataProvider {
    var contentText: String { get }
}

public struct CentreDataDisclaimerCellViewData: CentreDataDisclaimerCellViewDataProvider, Hashable {
    let contentText: String
}

final class CentreDataDisclaimerCell: UITableViewCell {
    @IBOutlet weak var infoIconImageView: UIImageView!
    @IBOutlet var contentTextTitleLabel: UILabel!
    @IBOutlet weak var disclaimerView: UIView!

    private enum Constant {
        static let disclaimerTextFont: UIFont = .accessibleSubheadRegular
        static let disclaimerTextColor: UIColor = .horsesNeck
        static let detailViewsCornerRadius: CGFloat = 15
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        contentView.backgroundColor = .athensGray
        selectionStyle = .none
    }

    func configure(with viewData: CentreDataDisclaimerCellViewDataProvider) {
        contentTextTitleLabel.text = viewData.contentText
        configureView()
    }

    func configureView() {
        infoIconImageView.image = UIImage(systemName: "info.circle.fill")?.tint(with: .horsesNeck)
        contentTextTitleLabel.font = Constant.disclaimerTextFont
        contentTextTitleLabel.textColor = Constant.disclaimerTextColor
        contentTextTitleLabel.adjustsFontForContentSizeCategory = true
        disclaimerView.setCornerRadius(Constant.detailViewsCornerRadius)
        disclaimerView.backgroundColor = .creamBrulee
    }
}
