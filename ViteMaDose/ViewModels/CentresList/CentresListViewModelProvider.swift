// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import UIKit
import MapKit

// MARK: - Centres List Section

public enum CentresListSection: CaseIterable {
    case heading
    case centres
}

// MARK: - Centres List Cell

public enum CentresListCell: Hashable {
    case title(HomeTitleCellViewData)
    case titleWithButton(CentreActionCellViewData)
    case stats(CentresStatsCellViewData)
    case centre(CentreViewData)
    case sort(CentresSortOptionsCellViewData)
    case disclaimer(CentreDataDisclaimerCellViewData)
}

// MARK: - Centres List View Model Provider

public protocol CentresListViewModelProvider: AnyObject {
    var delegate: CentresListViewModelDelegate? { get set }
    var filterOption: CentresListFilterOption { get }
    func load(animated: Bool)
    func sortList(by order: CentresListSortOption)
    func filterList(by type: CentresListFilterOption)
    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, location: CLLocation)?
    func phoneNumberLink(at indexPath: IndexPath) -> URL?
    func bookingLink(at indexPath: IndexPath) -> URL?
    func followCentre(at indexPath: IndexPath, notificationsType: FollowedCentre.NotificationsType)
    func unfollowCentre(at indexPath: IndexPath)
    func isCentreFollowed(at indexPath: IndexPath) -> Bool?
    func requestNotificationsAuthorizationIfNeeded(completion: @escaping () -> Void)
}

// MARK: - Centres List View Model Delegate

public protocol CentresListViewModelDelegate: AnyObject {
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)

    func presentLoadError(_ error: Error)
    func reloadTableView(
        with headingCells: [CentresListCell],
        andCentresCells centresCells: [CentresListCell],
        animated: Bool
    )
    func reloadTableViewFooter(with text: String?)
    func dismissViewController()
}
