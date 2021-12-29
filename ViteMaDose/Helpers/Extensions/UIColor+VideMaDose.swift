// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

private enum AssetsColor: String {
    case royalBlue
    case mandy
    case athensGray
    case creamBrulee
    case horsesNeck
}

extension UIColor {
    class var royalBlue: UIColor {
        guard let color = UIColor(named: AssetsColor.royalBlue.rawValue) else {
            fatalError("Could not find color")
        }
        return color
    }

    class var mandy: UIColor {
        guard let color = UIColor(named: AssetsColor.mandy.rawValue) else {
            fatalError("Could not find color")
        }
        return color
    }

    class var athensGray: UIColor {
        guard let color = UIColor(named: AssetsColor.athensGray.rawValue) else {
            fatalError("Could not find color")
        }
        return color
    }

    class var creamBrulee: UIColor {
        guard let color = UIColor(named: AssetsColor.creamBrulee.rawValue) else {
            fatalError("Could not find color")
        }
        return color
    }

    class var horsesNeck: UIColor {
        guard let color = UIColor(named: AssetsColor.horsesNeck.rawValue) else {
            fatalError("Could not find color")
        }
        return color
    }
}
