// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

protocol ClassNameProtocol {
    static var className: String { get }
}

/// Get a string from the object name
extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
}

/// Apply the protocol to any NSObject
extension NSObject: ClassNameProtocol { }
