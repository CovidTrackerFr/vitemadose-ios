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

    /// Medium text with headline text style, thus a size point of 13
    static var accessibleFootnoteLight: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.footnote).pointSize, weight: .light)
    }

    /// Regular text with headline text style, thus a size point of 15
    static var accessibleSubheadRegular: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.subheadline).pointSize, weight: .regular)
    }
    
    /// Medium text with headline text style, thus a size point of 15
    static var accessibleSubheadMedium: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.subheadline).pointSize, weight: .medium)
    }
    
    /// Semibold text with headline text style, thus a size point of 15
    static var accessibleSubheadSemiBold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.subheadline).pointSize, weight: .semibold)
    }

    /// Bold text with headline text style, thus a size point of 15
    static var accessibleSubheadBold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.subheadline).pointSize, weight: .bold)
    }
    
    /// Medium text with _callout_ text style, thus a size point of 16
    static var accessibleCalloutMedium: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.callout).pointSize, weight: .medium)
    }

    /// Bold text with _callout_ text style, thus a size point of 16
    static var accessibleCalloutBold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.callout).pointSize, weight: .bold)
    }
    
    /// Heavy text with _body_ text style, thus a size point of 17
    static var accessibleBodyHeavy: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body).pointSize, weight: .heavy)
    }
    
    /// Bold text with _body_ text style, thus a size point of 17
    static var accessibleBodyBold: UIFont {
        .rounded(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body).pointSize, weight: .bold)
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
