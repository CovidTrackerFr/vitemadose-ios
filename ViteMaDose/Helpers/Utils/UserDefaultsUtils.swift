//
//  UserDefaultsUtils.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 15/04/2021.
//

import Foundation

extension UserDefaults {

    // MARK: - Setup

    static let userDefaultSuiteName = "app.vitemadose.userdefaults"
    static let encoder = JSONEncoder()

    static let shared: UserDefaults = {
        let combined = UserDefaults.standard
        combined.addSuite(named: userDefaultSuiteName)
        return combined
    }()

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

    // MARK: - Keys

    private enum Key: String {
        case lastSearchResults
        case centresListSortOption
        case followedCentres
        case didPresentAppOnboarding
    }

    // MARK: - Last Selected Search Results

    var lastSearchResults: [LocationSearchResult] {
        get {
            let searchResultData = object(forKey: Key.lastSearchResults.rawValue) as? Data
            guard case let .success(results) = searchResultData?.decode([LocationSearchResult].self) else {
                return []
            }
            return results.unique(by: \.formattedName)
        }
        set {
            let results = newValue.unique(by: \.formattedName)
            guard let encoded = try? Self.encoder.encode(results) else {
                return
            }
            setValue(encoded, forKey: Key.lastSearchResults.rawValue)
        }
    }

    // MARK: - Centres List Sort Option

    var centresListSortOption: CentresListSortOption {
        get {
            guard let savedIndex = value(forKey: Key.centresListSortOption.rawValue) as? Int else {
                return .fastest
            }
            return CentresListSortOption(savedIndex)
        }
        set {
            setValue(newValue.index, forKey: Key.centresListSortOption.rawValue)
        }
    }

    // MARK: - Followed Centres

    var followedCentres: [String: Set<FollowedCentre>] {
        get {
            let followedCentresData = object(forKey: Key.followedCentres.rawValue) as? Data
            guard case let .success(followedCentres) = followedCentresData?.decode([String: Set<FollowedCentre>].self) else {
                return [:]
            }
            return followedCentres
        }
        set {
            guard let encoded = try? Self.encoder.encode(newValue) else {
                return
            }
            setValue(encoded, forKey: Key.followedCentres.rawValue)
        }
    }

    // MARK: - Did Present App Onboarding

    var didPresentAppOnboarding: Bool {
        get {
            let rawValue = bool(forKey: Key.didPresentAppOnboarding.rawValue)
            return rawValue
        }
        set {
            setValue(newValue, forKey: Key.didPresentAppOnboarding.rawValue)
        }
    }

    // MARK: - Helpers

    var hasFollowedCentres: Bool {
        return !followedCentres.values.map(\.isEmpty).allSatisfy({ $0 == true })
    }

    func followedCentre(forDepartment departmentCode: String, id: String) -> FollowedCentre? {
        return followedCentres[departmentCode]?.first(where: { $0.id == id })
    }

    func addFollowedCentre(_ centre: FollowedCentre, forDepartment departmentCode: String) {
        var updatedCentres = followedCentres
        let centresForCode = updatedCentres[departmentCode] ?? []
        updatedCentres[departmentCode] = centresForCode.union([centre])
        followedCentres = updatedCentres
    }

    func removedFollowedCentre(_ centreId: String, forDepartment departmentCode: String) {
        var updatedCentres = followedCentres
        if let centre = updatedCentres[departmentCode]?.first(where: { $0.id == centreId }) {
            updatedCentres[departmentCode]?.remove(centre)
        }
        followedCentres = updatedCentres
    }

    func isCentreFollowed(_ centreId: String, forDepartment departmentCode: String) -> Bool {
        return followedCentres[departmentCode]?.first(where: { $0.id == centreId }) != nil
    }
}
