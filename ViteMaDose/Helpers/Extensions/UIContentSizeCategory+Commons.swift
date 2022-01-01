// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.

import Foundation
import UIKit

extension UIContentSizeCategory {

    /// True if big text size is in use with accessibility feature enabled, false otherwise
    var isAccessibleLargeTextSize: Bool {
        switch self {
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge,
            UIContentSizeCategory.accessibilityExtraExtraLarge,
            UIContentSizeCategory.accessibilityExtraLarge,
            UIContentSizeCategory.accessibilityLarge,
            UIContentSizeCategory.accessibilityMedium:
            return true
        default:
            return false
        }
    }
}
