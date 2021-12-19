//
//  CentresListSortOption.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/05/2021.
//

import Foundation

public enum CentresListSortOption: Equatable {
    case closest
    case fastest
    case thirdDose

    init(_ value: Int) {
        switch value {
        case 0:
            self = .closest
        case 1:
            self = .fastest
        case 2:
            self = .thirdDose
        default:
            assertionFailure("Value should either be 0, 1 or 2")
            self = .closest
        }
    }

    var index: Int {
        switch self {
        case .closest:
            return 0
        case .fastest:
            return 1
        case .thirdDose:
            return 2
        }
    }
}
