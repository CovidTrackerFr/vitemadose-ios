// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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
