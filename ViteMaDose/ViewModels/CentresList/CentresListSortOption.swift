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

    init(_ value: Int) {
        switch value {
        case 0:
            self = .closest
        case 1:
            self = .fastest
        default:
            assertionFailure("Value should either be 0 or 1")
            self = .closest
        }
    }

    var index: Int {
        switch self {
        case .closest:
            return 0
        case .fastest:
            return 1
        }
    }
}
