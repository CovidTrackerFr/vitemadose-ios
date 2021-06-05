//
//  HomeViewModelDelegateSpy.swift
//  ViteMaDoseTests
//
//  Created by Victor Sarda on 25/04/2021.
//

import Foundation
@testable import ViteMaDose

final class HomeViewModelDelegateSpy: HomeViewModelDelegate {
    var updateLoadingState: (isLoading: Bool, isEmpty: Bool)?
    func updateLoadingState(isLoading: Bool, isEmpty: Bool) {
        updateLoadingState = (isLoading, isEmpty)
    }

    var presentVaccinationCentresLocationSearchResult: LocationSearchResult?
    func presentVaccinationCentres(for location: LocationSearchResult) {
        presentVaccinationCentresLocationSearchResult = location
    }

    var presentFetchStatsError: Error?
    func presentFetchStatsError(_ error: Error) {
        presentFetchStatsError = error
    }

    var reloadTableView: (headingCells: [HomeCell], statsCells: [HomeCell])?
    func reloadTableView(with headingCells: [HomeCell], andStatsCells statsCells: [HomeCell]) {
        reloadTableView = (headingCells, statsCells)
    }
}
