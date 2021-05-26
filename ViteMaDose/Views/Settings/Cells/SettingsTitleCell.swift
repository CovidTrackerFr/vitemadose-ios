// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GPL-3.0
//
// This software is distributed under the GNU General Public License v3.0 only.
//
// Author: Pierre-Yves LAPERSONNE <dev(at)pylapersonne(dot)info> et al.

import UIKit

final class SettingsTitleCell: HomeTitleCell {
    private enum Constant {
        static let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold) // FIXME: A11Y
        static let titleColor: UIColor = .label
    }
}

extension SettingsTitleCell {

    static func mainTitleAttributedText() -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]
        let title = NSMutableAttributedString(
            string: Localization.Settings.title,
            attributes: attributes
        )
        return title
    }
}
