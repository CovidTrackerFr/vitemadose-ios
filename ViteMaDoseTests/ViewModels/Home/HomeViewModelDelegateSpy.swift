//
//  HomeViewModelDelegateSpy.swift
//  ViteMaDoseTests
//
//  Created by Victor Sarda on 25/04/2021.
//

import Foundation
@testable import ViteMaDose

class HomeViewModelDelegateSpy: HomeViewModelDelegate {
    var updateLoadingState: (isLoading: Bool, isEmpty: Bool)?
    func updateLoadingState(isLoading: Bool, isEmpty: Bool) {
        updateLoadingState = (isLoading, isEmpty)
    }

    var presentVaccinationCentresDepartment: Department?
    func presentVaccinationCentres(for departments: Department) {
        presentVaccinationCentresDepartment = departments
    }

    var presentInitialLoadError: Error?
    func presentInitialLoadError(_ error: Error) {
        presentInitialLoadError = error
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
