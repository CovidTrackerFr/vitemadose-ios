//
//  UIView+Common.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

extension UIView {
    class func instanceFromNib<T: UIView>(bundle: Bundle = Bundle.main) -> T {
        return bundle.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
