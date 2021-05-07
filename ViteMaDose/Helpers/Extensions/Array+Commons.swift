//
//  Array+Commons.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 03/05/2021.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension RangeReplaceableCollection {
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> Self {
        var unique = Set<T>()
        return filter { unique.insert($0[keyPath: keyPath]).inserted }
    }
}
