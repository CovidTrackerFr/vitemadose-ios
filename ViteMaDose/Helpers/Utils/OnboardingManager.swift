//
//  OnboardingManager.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/05/2021.
//

import UIKit
import BLTNBoard

enum OnboardingManager {
    private static let titleFontSize: CGFloat = 24.0
    private static let descriptionFontSize: CGFloat = 18.0

    static func makeFirstPage() -> BLTNPageItem {
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
        page.next = makeNotificationsPage()
        return page
    }

    static func makeNotificationsPage() -> BLTNPageItem {
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
            item.manager?.dismissBulletin()
        }
        return page
    }
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
