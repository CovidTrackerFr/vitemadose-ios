//
//  UserDefaultsUtils.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 15/04/2021.
//

import Foundation

extension UserDefaults {

    // MARK: - Setup

    static let userDefaultSuiteName = "app.vitemadose"
    static let encoder = JSONEncoder()

    static var shared: UserDefaults {
        let combined = UserDefaults.standard
        combined.addSuite(named: userDefaultSuiteName)
        return combined
    }

    /// Testing purposes only
    /// - Returns: Cleared UserDefault instance
    static func makeClearedInstance(
        for functionName: StaticString = #function,
        inFile fileName: StaticString = #file
    ) -> UserDefaults {
        let className = "\(fileName)".split(separator: ".")[0]
        let testName = "\(functionName)".split(separator: "(")[0]
        let suiteName = "\(userDefaultSuiteName)\(className).\(testName)"

        let defaults = self.init(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    // MARK: Keys

    private enum Key: String {
        case lastSearchResult
    }

    // MARK: Last Selected Search Result

    var lastSearchResult: [LocationSearchResult] {
        get {
            guard let searchResult = object(forKey: Key.lastSearchResult.rawValue) as? Data else {
                return []
            }
            return searchResult.decode([LocationSearchResult].self) ?? []
        }
        set {
            guard let encoded = try? Self.encoder.encode(newValue) else {
                return
            }
            setValue(encoded, forKey: Key.lastSearchResult.rawValue)
        }
    }

}
