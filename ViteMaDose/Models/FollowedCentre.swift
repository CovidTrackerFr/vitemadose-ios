// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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
    }
}
