// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

protocol Storyboarded: AnyObject {
    static var storyboard: UIStoryboard { get }
}

extension Storyboarded {
    static var storyboard: UIStoryboard {
        return UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
    }
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("The view controller is not of class: \(self)")
        }
        return viewController
    }
}
