// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit
import BLTNBoard

enum OnboardingManager {
    private static let titleFontSize: CGFloat = 24.0
    private static let descriptionFontSize: CGFloat = 18.0

    static let welcomePage: BLTNPageItem = {
        let page = BLTNPageItem(title: Localization.Onboarding.WelcomePage.title)
        page.image = "🎉".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .royalBlue

        page.appearance = appearance
        page.descriptionText = Localization.Onboarding.WelcomePage.description
        page.actionButtonTitle = Localization.Onboarding.next_button
        page.alternativeButton?.isHidden = true
        page.isDismissable = false
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        page.next = notificationsPage
        return page
    }()

    static let notificationsPage: BLTNPageItem = {
        let page = BLTNPageItem(title: Localization.Onboarding.NotificationsPage.title)
        page.image = "🔔".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .royalBlue

        page.appearance = appearance
        page.descriptionText = Localization.Onboarding.NotificationsPage.description
        page.actionButtonTitle = Localization.Onboarding.next_button
        page.alternativeButton?.isHidden = true
        page.isDismissable = false
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        page.next = thirdDosePage

        return page
    }()

    static let thirdDosePage: BLTNPageItem = {
        let page = BLTNPageItem(title: Localization.Onboarding.ThirdDosePage.title)
        page.image = "✅".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .royalBlue

        page.appearance = appearance
        page.descriptionText = Localization.Onboarding.ThirdDosePage.description
        page.actionButtonTitle = Localization.Onboarding.next_button
        page.alternativeButton?.isHidden = true
        page.isDismissable = false
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        page.next = settingsPage

        return page
    }()

    static let settingsPage: BLTNPageItem = {
        let page = BLTNPageItem(title: Localization.Onboarding.SettingsPage.title)
        page.image = "📚".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .royalBlue

        page.appearance = appearance
        page.descriptionText = Localization.Onboarding.SettingsPage.description
        page.descriptionText = Localization.Onboarding.SettingsPage.description
        page.actionButtonTitle = Localization.Onboarding.next_button
        page.alternativeButton?.isHidden = true
        page.isDismissable = false
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        page.next = kidsFirstDosePage

        return page
    }()

    static let kidsFirstDosePage: BLTNPageItem = {
        let page = BLTNPageItem(title: Localization.Onboarding.KidsFirstDoses.title)
        page.image = "🧸".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .royalBlue

        page.appearance = appearance
        page.descriptionText = Localization.Onboarding.KidsFirstDoses.description
        page.actionButtonTitle = Localization.Onboarding.done_button
        page.alternativeButton?.isHidden = true
        page.isDismissable = false
        page.actionHandler = { item in
            item.manager?.dismissBulletin()
        }

        return page
    }()
}

extension String {
    func toImage(ofSize size: CGFloat) -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: size)
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
}
