//
//  UIContentSizeCategory+Commons.swift
//  ViteMaDose
//
//  Created by Pierre-Yvee Lapersonne on 01/01/2022.
//

import Foundation
import UIKit

extension UIContentSizeCategory {
    
    var isAccessibleLargeTextSize: Bool {
        switch self {
           case UIContentSizeCategory.accessibilityExtraExtraExtraLarge,
            UIContentSizeCategory.accessibilityExtraExtraLarge,
            UIContentSizeCategory.accessibilityExtraLarge,
            UIContentSizeCategory.accessibilityLarge,
            UIContentSizeCategory.accessibilityMedium:
               return true
            default:
                return false
        }
    }
}
