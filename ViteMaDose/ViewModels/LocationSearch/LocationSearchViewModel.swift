//
//  LocationSearchViewModel.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation
import Moya
import MapKit

enum LocationSearchSection: CaseIterable {
    case list
}

enum LocationSearchCell: Hashable {
    case searchResult(LocationSearchResultCellViewData)
}

enum LocationSearchStrategy {
    case withPostCode(code: String)
    case withName(name: String)

    init?(query: String) {
        guard
            let firstCharacter = query.first,
            query.count > 1
        else {
            return nil
        }

        if firstCharacter.isNumber, query.count == 5 {
            self = .withPostCode(code: query)
        } else {
            self = .withName(name: query)
        }
    }
}

protocol LocationSearchViewModelProvider {
    func loadDepartments()
    func search(query: String)
    func didSelectCell(at indexPath: IndexPath)
}

protocol LocationSearchViewModelDelegate: AnyObject {
    func reloadTableView(with cells: [LocationSearchCell])
    func dismissViewController(with department: LocationSearchResult)
}

// MARK: - LocationSearchViewModel

class LocationSearchViewModel: LocationSearchViewModelProvider {
    private let geoAPIService: GeoAPIServiceProvider
    private let userDefaults: UserDefaults
    weak var delegate: LocationSearchViewModelDelegate?

    private let departments: Departments
    private var searchStrategy: LocationSearchStrategy?
    private var searchResults: [LocationSearchResult] = [] {
        didSet {
            updateCells()
        }
    }

    // MARK: init

    required init(
        geoAPIService: GeoAPIServiceProvider = GeoAPIService(),
        departments: Departments = Department.list,
        userDefaults: UserDefaults = .shared
    ) {
        self.geoAPIService = geoAPIService
        self.departments = departments
        self.userDefaults = userDefaults
    }

    func loadDepartments() {
        searchResults = departments.map(\.asLocationSearchResult)
    }

    private func updateCells() {
        let cells = searchResults.map(createLocationSearchResultCell)
        delegate?.reloadTableView(with: cells)
    }

    func search(query: String) {
        searchStrategy = LocationSearchStrategy(query: query)
        let foundDepartmentsResult = searchInDepartmentsList(query: query)

        let fetchCitiesCompletion: (Cities) -> Void = { [weak self] cities in
            guard let self = self else { return }
            let citiesResult = cities.compactMap(self.cityAsLocationSearchResult)
            self.searchResults = (citiesResult + foundDepartmentsResult).unique(by: \.hashValue)
        }

        switch searchStrategy {
        case let .withName(name):
            geoAPIService.fetchCities(byName: name, completion: fetchCitiesCompletion)
        case let .withPostCode(code):
            geoAPIService.fetchCities(byPostCode: code, completion: fetchCitiesCompletion)
        case .none:
            loadDepartments()
        }
    }

    private func cityAsLocationSearchResult(_ city: City) -> LocationSearchResult? {
        guard
            let departmentCode = city.departement?.code,
            var name = city.nom
        else {
            return nil
        }

        if case let .withPostCode(code) = searchStrategy {
            name.append(String.space + "(\(code))")
        }

        return LocationSearchResult(
            name: name,
            departmentCode: departmentCode,
            nearDepartmentCodes: city.departement?.nearDepartments ?? [],
            coordinates: city.coordinates
        )
    }

    func didSelectCell(at indexPath: IndexPath) {
        guard let searchResult = searchResults[safe: indexPath.row] else {
            assertionFailure("Search result not found at indexPath \(indexPath)")
            return
        }

        var lastSearchResults = userDefaults.lastSearchResults
        guard !lastSearchResults.contains(searchResult) else {
            delegate?.dismissViewController(with: searchResult)
            return
        }

        updateLastSearchResults(withSearchResult: searchResult, in: &lastSearchResults)
        userDefaults.lastSearchResults = lastSearchResults
        delegate?.dismissViewController(with: searchResult)
    }

    private func updateLastSearchResults(
        withSearchResult searchResult: LocationSearchResult,
        in localSearchResults: inout [LocationSearchResult]
    ) {
        // Limit list to 3 results
        if localSearchResults.count >= 3 {
            localSearchResults.insert(searchResult, at: 0)
            localSearchResults.removeLast()
        } else {
            localSearchResults.append(searchResult)
        }
    }

    private func createLocationSearchResultCell(for searchResult: LocationSearchResult) -> LocationSearchCell {
        let viewData = LocationSearchResultCellViewData(
            titleText: nil,
            name: searchResult.name,
            code: searchResult.departmentCode
        )
        return .searchResult(viewData)
    }

    private func searchInDepartmentsList(query: String) -> [LocationSearchResult] {
        let lowerCasedQuery = query.lowercased()
        return departments
            .map(\.asLocationSearchResult)
            .filter({
                let lowerCasedName = $0.name.lowercased()
                let lowerCaseCode = $0.departmentCode.lowercased()
                return
                    lowerCasedName.contains(lowerCasedQuery) ||
                    lowerCaseCode.contains(lowerCasedQuery)
            })
    }
}
