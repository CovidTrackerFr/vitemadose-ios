// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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

public protocol OptionalProtocol {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Sequence where Element: OptionalProtocol {
    var compacted: [Element.Wrapped] {
        return compactMap(\.value)
    }
}

extension Optional: OptionalProtocol {
    public var value: Wrapped? {
        switch self {
        case .none:
            return nil
        case let .some(value):
            return value
        }
    }
}
