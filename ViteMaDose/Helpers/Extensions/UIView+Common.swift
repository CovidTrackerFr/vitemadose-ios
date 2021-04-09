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

    func dropShadow(
        color: UIColor,
        opacity: Float = 0.5,
        offSet: CGSize = .zero,
        radius: CGFloat = 1,
        scale: Bool = true
    ) {
        layer.masksToBounds = true
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
