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

final class LocationSearchViewModel: LocationSearchViewModelProvider {
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
            let citiesResult = cities
                .map(self.cityAsLocationSearchResult)
                .unique(by: \.formattedName)
                .sorted(by: { LocationSearchResult.sortByBestMatch(query, $0, $1) })

            self.searchResults = foundDepartmentsResult + citiesResult
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

    private func cityAsLocationSearchResult(_ city: City) -> LocationSearchResult {
        var postCode: String?
        if case let .withPostCode(code) = searchStrategy {
             postCode = code
        } else if let firstPostCode = city.postCode {
            postCode = firstPostCode
        }

        return LocationSearchResult(
            name: city.nom,
            postCode: postCode,
            selectedDepartmentCode: city.departement.code,
            departmentCodes: city.departement.nearDepartments,
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
            name: searchResult.formattedName,
            postCode: searchResult.postCode,
            departmentCode: searchResult.selectedDepartmentCode.emptyIfNil
        )
        return .searchResult(viewData)
    }

    private func searchInDepartmentsList(query: String) -> [LocationSearchResult] {
        return departments
            .map(\.asLocationSearchResult)
            .unique(by: \.name)
            .filter({ LocationSearchResult.filterDepartmentsByQuery(query, $0) })
            .sorted(by: { LocationSearchResult.sortByBestMatch(query, $0, $1) })
    }
}
