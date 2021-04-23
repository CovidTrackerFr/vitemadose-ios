//
//  UIViewController+Commons.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import UIKit

extension UIViewController {
    var embedInNavigationController: UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
