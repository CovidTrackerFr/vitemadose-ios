// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

final class SettingsTitleCell: HomeTitleCell {
    private enum Constant {
        static let titleFont: UIFont = .accessibleTitle2Bold
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
