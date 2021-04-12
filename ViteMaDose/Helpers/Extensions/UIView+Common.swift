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

    func setCornerRadius(_ cornerRadius: CGFloat, withShadow shadow: Shadow? = nil) {
        layer.cornerRadius = cornerRadius
        guard let shadow = shadow else {
            return
        }

        layer.shadowColor = shadow.color
        layer.shadowOffset = shadow.offset
        layer.shadowOpacity = shadow.opacity
        layer.shadowRadius = shadow.radius ?? cornerRadius
    }

    func dropShadow(
        color: UIColor,
        opacity: Float = 0.5,
        offSet: CGSize = .zero,
        radius: CGFloat = 1,
        scale: Bool = true
    ) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    struct Shadow {
        let color: CGColor
        let opacity: Float
        let offset: CGSize
        let radius: CGFloat?

        init(
            color: UIColor = .black,
            opacity: Float = 0.5,
            offset: CGSize = .zero,
            radius: CGFloat? = nil
        ) {
            self.color = color.cgColor
            self.opacity = opacity
            self.offset = offset
            self.radius = radius
        }
    }
}
