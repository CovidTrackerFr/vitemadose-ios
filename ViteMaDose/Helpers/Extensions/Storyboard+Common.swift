//
//  Storyboard+Common.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

protocol Storyboarded: class {
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
