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

    var presentVaccinationCentresCounty: County?
    func presentVaccinationCentres(for county: County) {
        presentVaccinationCentresCounty = county
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
    func reloadTableView(with headingCells: [HomeCell], andStatsCells: [HomeCell]) {
        reloadTableView = (headingCells, andStatsCells)
    }

    var reloadHeadingSection: [HomeCell]?
    func reloadHeadingSection(with headingCells: [HomeCell]) {
        reloadHeadingSection = headingCells
    }

    var reloadStatsSection: [HomeCell]?
    func reloadStatsSection(with statsCells: [HomeCell]) {
        reloadStatsSection = statsCells
    }
}
