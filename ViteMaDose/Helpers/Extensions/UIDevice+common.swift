// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import UIKit

extension UIDevice {

    var isUnderiOS15: Bool {
        guard let version = Float(self.systemVersion) else {
            return false
        }
        return version < 15.0
    }

    var isUnderiOS14: Bool {
        guard let version = Float(self.systemVersion) else {
            return false
        }
        return version < 14.0
    }
}
