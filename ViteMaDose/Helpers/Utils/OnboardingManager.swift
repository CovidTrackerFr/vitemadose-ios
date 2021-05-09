//
//  OnboardingManager.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/05/2021.
//

import UIKit
import BLTNBoard

struct OnboardingManager {
    static let shared = OnboardingManager()
    private init() {}

    // TODO: Texts
    func makeNotificationsPage(
        actionHandler: @escaping (BLTNActionItem) -> Void,
        alternativeHandler: @escaping ((BLTNActionItem) -> Void)
    ) -> BLTNPageItem {
        let page = BLTNPageItem(title: "Push Notifications")
        page.image = UIImage(systemName: "app.badge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))?.tint(with: .systemRed)

        page.descriptionText = "Receive push notifications when new photos of pets are available."
        page.actionButtonTitle = "Subscribe"
        page.alternativeButtonTitle = "Not now"

        page.isDismissable = false

        page.actionHandler = actionHandler
        page.alternativeHandler = alternativeHandler

        return page
    }
}
