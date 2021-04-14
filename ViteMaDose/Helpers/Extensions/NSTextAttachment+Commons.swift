//
//  NSTextAttachment+Commons.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 14/04/2021.
//

import UIKit

extension NSTextAttachment {
    convenience init(rightImage image: UIImage, height: CGFloat, offset: CGFloat) {
        self.init()
        self.image = image

        let ratio = image.size.width / image.size.height
        bounds = CGRect(
            x: bounds.origin.x + offset,
            y: bounds.origin.y - 5,
            width: ratio * height,
            height: height
        )
    }

    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}
