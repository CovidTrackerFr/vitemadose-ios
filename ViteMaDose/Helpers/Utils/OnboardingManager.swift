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
        let page = BLTNPageItem(title: "Vite Ma Dose fait le plein de nouveautés !")
        page.image = "🎉".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .royalBlue

        page.appearance = appearance
        page.descriptionText = "Découvrez les notifications pour ne rater aucune dose, et les chronodoses permettant à chacun de trouver un rendez-vous en 24h sans restriction."
        page.actionButtonTitle = "Suivant"
        page.alternativeButton?.isHidden = true
        page.isDismissable = false
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        page.next = makeNotificationsPage()
        return page
    }

    static func makeNotificationsPage() -> BLTNPageItem {
        let page = BLTNPageItem(title: "Notifications")
        page.image = "🔔".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .royalBlue

        page.appearance = appearance
        page.descriptionText = "Pour ne rater aucun créneau de vaccination, nous avons ajouté un système de notifications ! Pour vous abonner à un centre, rien de plus simple, il suffit de toucher la cloche. Vous recevrez une alerte si nous détectons des disponibilités."
        page.actionButtonTitle = "Suivant"
        page.alternativeButton?.isHidden = true
        page.isDismissable = false
        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        page.next = makeChronoDosesPage()

        return page
    }

    static func makeChronoDosesPage() -> BLTNPageItem {
        let page = BLTNPageItem(title: "Chronodoses")
        page.image = "⚡️".toImage(ofSize: 60)

        let appearance = BLTNItemAppearance()
        appearance.titleFontSize = Self.titleFontSize
        appearance.descriptionFontSize = Self.descriptionFontSize
        appearance.actionButtonColor = .mandy

        page.appearance = appearance
        page.descriptionText = "À partir du mercredi 12 mai, vous pourrez réserver les rendez-vous de vaccination vacants du jour même et du lendemain, sans restriction. Nous les appelons les “Chronodoses”, et sont matérialisées par des éclairs et un bandeau rouge."
        page.actionButtonTitle = "Merci !"
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
