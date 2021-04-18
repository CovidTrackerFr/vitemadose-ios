//
//  UserDefaultsWrapper.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 15/04/2021.
//

import Foundation

@propertyWrapper
final class UserDefault<T> {
    private let defaults: UserDefaults
    let key: Key
    let defaultValue: T

    var projectedValue: String { key.rawValue }

    var wrappedValue: T {
        get { defaults.object(forKey: key.rawValue) as? T ?? defaultValue }
        set {
            defaults.set(newValue, forKey: key.rawValue)
        }
    }

    init(wrappedValue: T, key: Key, userDefault: UserDefaults = .standard) {
        self.defaultValue = wrappedValue
        self.key = key
        self.defaults = userDefault
    }
}

extension UserDefault {
    enum Key: String {
        case lastSelectedCountyCode
    }
}

@propertyWrapper
final class OptionalUserDefault<T> {
    private var defaults: UserDefaults = .standard
    let key: UserDefault<T>.Key

    var projectedValue: String { key.rawValue }

    var wrappedValue: T? {
        get { defaults.object(forKey: key.rawValue) as? T }
        set {
            if newValue == nil {
                defaults.removeObject(forKey: key.rawValue)
            } else {
                defaults.set(newValue, forKey: key.rawValue)
            }
        }
    }

    init(wrappedValue: T? = nil, key: UserDefault<T>.Key, userDefault: UserDefaults = .standard) {
        self.key = key
        self.defaults = userDefault
    }
}

extension UserDefaults {
    @OptionalUserDefault(key: .lastSelectedCountyCode)
    static var lastSelectedCountyCode: String?
}
