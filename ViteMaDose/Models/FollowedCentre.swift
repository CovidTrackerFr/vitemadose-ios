//
//  FollowedCentre.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 08/05/2021.
//

import Foundation

public struct FollowedCentre: Codable, Identifiable, Hashable {
    public let id: String
    let notificationsType: NotificationsType
}

public extension FollowedCentre {
    enum NotificationsType: String, Codable, Hashable {
        case none
        case all
        case chronodoses
    }
}
