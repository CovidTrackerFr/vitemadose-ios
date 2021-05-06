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
        case lastSearchResults
        case centresListSortOption
    }

    // MARK: Last Selected Search Results

    var lastSearchResults: [LocationSearchResult] {
        get {
            let searchResultData = object(forKey: Key.lastSearchResults.rawValue) as? Data
            guard case let .success(results) = searchResultData?.decode([LocationSearchResult].self) else {
                return []
            }
            return results
        }
        set {
            guard let encoded = try? Self.encoder.encode(newValue.uniqued()) else {
                return
            }
            setValue(encoded, forKey: Key.lastSearchResults.rawValue)
        }
    }

    var centresListSortOption: CentresListSortOption {
        get {
            guard let savedIndex = value(forKey: Key.centresListSortOption.rawValue) as? Int else {
                return .closest
            }
            return CentresListSortOption(savedIndex)
        }
        set {
            setValue(newValue.index, forKey: Key.centresListSortOption.rawValue)
        }
    }

}
