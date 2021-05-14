//
//  CentresListViewModelProvider.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/05/2021.
//

import Foundation
import UIKit
import MapKit

public enum CentresListSection: CaseIterable {
    case heading
    case centres
}

public enum CentresListCell: Hashable {
    case title(HomeTitleCellViewData)
    case stats(CentresStatsCellViewData)
    case centre(CentreViewData)
    case sort(CentresSortOptionsCellViewData)
}

public protocol CentresListViewModelProvider: AnyObject {
    var delegate: CentresListViewModelDelegate? { get set }
    func load(animated: Bool)
    func sortList(by order: CentresListSortOption)
    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, location: CLLocation)?
    func phoneNumberLink(at indexPath: IndexPath) -> URL?
    func bookingLink(at indexPath: IndexPath) -> URL?
    func followCentre(at indexPath: IndexPath, notificationsType: FollowedCentre.NotificationsType)
    func unfollowCentre(at indexPath: IndexPath)
    func isCentreFollowed(at indexPath: IndexPath) -> Bool?
    func requestNotificationsAuthorizationIfNeeded(completion: @escaping () -> Void)
}

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
