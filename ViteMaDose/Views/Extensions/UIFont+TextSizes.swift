// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GPL-3.0
//
// This software is distributed under the GNU General Public License v3.0 only.
//
// Author: Pierre-Yves LAPERSONNE <dev(at)pylapersonne(dot)info> et al.

import Foundation
import UIKit

/// Extension which provide `UIFont` prepared for accessibility and ready to be integrated in the app UI.
/// More details about size points values here: //https://sarunw.com/posts/scaling-custom-fonts-automatically-with-dynamic-type/
extension UIFont {

    /// Medium text with headline text style, thus a size point of 15
    static var accessibleSubheadSemiBold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.subheadline).pointSize, weight: .semibold)
    }

    /// Medium text with _callout_ text style, thus a size point of 16
    static var accessibleCalloutMedium: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.callout).pointSize, weight: .medium)
    }

    /// Bold text with _callout_ text style, thus a size point of 16
    static var accessibleCalloutBold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.callout).pointSize, weight: .bold)
    }
    
    /// Bold text with _title2_ text style, thus a size point of 22
    static var accessibleTitle2Bold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.title2).pointSize, weight: .bold)
    }

    /// Bold text with _title1_ text style, thus a size point of 28
    static var accessibleTitle1Bold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.title1).pointSize, weight: .bold)
    }

    /// Bold text with _largeTitle_ text style, thus a size point of 34
    static var accessibleLargeTitleBold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.largeTitle).pointSize, weight: .bold)
    }
}
