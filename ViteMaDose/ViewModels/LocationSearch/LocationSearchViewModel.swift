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
    private var searchResults: [LocationSearchResult] = [] {
        didSet {
            updateCells()
        }
    }

    // MARK: init

    required init(
        geoAPIService: GeoAPIServiceProvider = GeoAPIService(),
        departments: Departments,
        userDefaults: UserDefaults = .shared
    ) {
        self.geoAPIService = geoAPIService
        self.departments = departments
        self.userDefaults = userDefaults
    }

    func loadDepartments() {
        searchResults = departments.map(\.asLocationSearchResult)
    }

    func search(query: String) {
        guard let searchStrategy = LocationSearchStrategy(query: query) else {
            loadDepartments()
            return
        }

        let foundDepartmentsResult = searchInDepartmentsList(query: query)
        var postCode: String?

        let fetchCitiesCompletion: (Cities) -> Void = { [weak self] cities in
            guard let self = self else { return }
            let citiesResult = cities.compactMap { city -> LocationSearchResult? in
                guard
                    let departmentCode = city.departement?.code,
                    var name = city.nom
                else {
                    return nil
                }

                if let postCode = postCode {
                    name.append(String.space + "(\(postCode))")
                }

                return LocationSearchResult(
                    name: name,
                    departmentCode: departmentCode,
                    departmentCodes: city.departement?.nearDepartments ?? [],
                    coordinates: city.coordinates
                )
            }

            self.searchResults = citiesResult + foundDepartmentsResult
        }

        switch searchStrategy {
        case let .withName(name):
            geoAPIService.fetchCities(byName: name, completion: fetchCitiesCompletion)
        case let .withPostCode(code):
            postCode = code
            geoAPIService.fetchCities(byPostCode: code, completion: fetchCitiesCompletion)
        }
    }

    func didSelectCell(at indexPath: IndexPath) {
        guard let searchResult = searchResults[safe: indexPath.row] else {
            assertionFailure("Search result not found at indexPath \(indexPath)")
            return
        }
        var lastSearchResults = userDefaults.lastSearchResult
        guard !lastSearchResults.contains(searchResult) else {
            delegate?.dismissViewController(with: searchResult)
            return
        }

        if lastSearchResults.count >= 3 {
            lastSearchResults.insert(searchResult, at: 0)
            lastSearchResults.removeLast()
        } else {
            lastSearchResults.append(searchResult)
        }
        
        userDefaults.lastSearchResult = lastSearchResults
        delegate?.dismissViewController(with: searchResult)
    }

    private func updateCells() {
        let cells: [LocationSearchCell] = searchResults.compactMap { searchResult in
            let viewData = LocationSearchResultCellViewData(
                titleText: nil,
                name: searchResult.name,
                code: searchResult.departmentCode
            )
            return .searchResult(viewData)
        }
        delegate?.reloadTableView(with: cells)
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
