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
        case lastSelectedCountyCode
    }

    // MARK: Last Selected County Code

    var lastSelectedCountyCode: String? {
        get {
            let rawValue = string(forKey: Key.lastSelectedCountyCode.rawValue)
            return rawValue
        }
        set {
            setValue(newValue, forKey: Key.lastSelectedCountyCode.rawValue)
        }
    }

}
