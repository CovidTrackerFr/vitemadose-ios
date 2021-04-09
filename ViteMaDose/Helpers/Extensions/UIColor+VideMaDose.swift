//
//  UIColor+VideMaDose.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 08/04/2021.
//

import UIKit

private enum AssetsColor: String {
    case royalBlue
    case mandy
    case mercury
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

    class var mercury: UIColor {
        guard let color = UIColor(named: AssetsColor.mercury.rawValue) else {
            fatalError("Could not find color")
        }
        return color
    }
}
