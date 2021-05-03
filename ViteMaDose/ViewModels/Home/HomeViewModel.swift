//
//  HomeViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit
import Moya

// MARK: - Home Cell ViewModel

enum HomeSection: CaseIterable {
    case heading
    case stats
}

enum HomeCell: Hashable {
    case title(HomeTitleCellViewData)
    case departmentSelection(HomeDepartmentSelectionViewData)
    case department(HomeDepartmentCellViewData)
    case stats(HomeCellStatsViewData)
}

// MARK: - Home ViewModel

protocol HomeViewModelProvider {
    func load()
    func reloadStats()
    func didSelectSavedSearchResult(withName name: String)
    func didSelect(_ location: LocationSearchResult)

    var departments: Departments { get }
    var stats: Stats? { get }
}

protocol HomeViewModelDelegate: AnyObject {
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)

    func presentVaccinationCentres(for location: LocationSearchResult)
    func presentInitialLoadError(_ error: Error)
    func presentFetchStatsError(_ error: Error)

    func reloadTableView(with headingCells: [HomeCell], andStatsCells statsCells: [HomeCell])
}

class HomeViewModel {
    private let apiService: BaseAPIServiceProvider
    private let userDefaults: UserDefaults
    weak var delegate: HomeViewModelDelegate?

    let departments: Departments
    var stats: Stats?

    private var isLoading = false {
        didSet {
            let isEmpty = departments.isEmpty && stats == nil
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: isEmpty)
        }
    }

    private var headingCells: [HomeCell] = []
    private var statsCell: [HomeCell] = []

    // MARK: init

    required init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        departments: Departments = Department.list,
        userDefaults: UserDefaults = .shared
    ) {
        self.apiService = apiService
        self.departments = departments
        self.userDefaults = userDefaults
    }

    // MARK: Handle API result

    private func handleInitialLoad(stats: Stats) {
        self.stats = stats

        updateHeadingCells()
        updateStatsCells()

        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell)
    }

    private func handleStatsReload(with stats: Stats) {
        self.stats = stats
        updateStatsCells()
        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell)
    }

    private func handleLastSelectedSearchResult() {
        updateHeadingCells()
        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell)
    }

    private func updateHeadingCells() {
        let titleCellViewData = HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText, bottomMargin: 0)
        let departmentSelectionViewData = HomeDepartmentSelectionViewData()
        let lastSelectedDepartmentViewData = getLastSelectedDepartmentCellViewData()

        headingCells = [
            .title(titleCellViewData),
            .departmentSelection(departmentSelectionViewData)
        ]

        for viewData in lastSelectedDepartmentViewData {
            headingCells.append(.department(viewData))
        }
    }

    private func updateStatsCells() {
        guard let departmentsStats = stats?[StatsKey.allDepartments.rawValue] else {
            return
        }

        let statsTitleViewModel = HomeTitleCellViewData(titleText: HomeTitleCell.lastStatsAttributedText, topMargin: 20, bottomMargin: 5)
        let allCentresViewModel = HomeCellStatsViewData(.allCentres(departmentsStats.total))
        let centresWithAvailabilitiesViewModel = HomeCellStatsViewData(.centresWithAvailabilities(departmentsStats.disponibles))
        let allAvailabilitiesViewModel = HomeCellStatsViewData(.allAvailabilities(departmentsStats.creneaux))
        let percentageAvailabilitiesViewModel = HomeCellStatsViewData(.percentageAvailabilities(departmentsStats.pourcentage))
        let externalMapViewModel = HomeCellStatsViewData(.externalMap)

        statsCell = [
            .title(statsTitleViewModel),
            .stats(allCentresViewModel),
            .stats(allAvailabilitiesViewModel),
            .stats(centresWithAvailabilitiesViewModel),
            .stats(percentageAvailabilitiesViewModel),
            .stats(externalMapViewModel)
        ]
    }

    private func getLastSelectedDepartmentCellViewData() -> [HomeDepartmentCellViewData] {
        let lastSearchResults = userDefaults.lastSearchResult
        return lastSearchResults.enumerated().map { index, location in
            HomeDepartmentCellViewData(
                titleText: index == 0 ? Localization.Home.recent_search : nil,
                name: location.name,
                code: location.departmentCode
            )
        }
    }

    private func handleInitialLoadError(_ error: Error) {
        delegate?.presentInitialLoadError(error)
    }

    private func handleStatsError(_ error: Error) {
        delegate?.presentFetchStatsError(error)
    }
}

// MARK: - HomeViewModelProvider

extension HomeViewModel: HomeViewModelProvider {
    func load() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchStats { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case let .success(stats):
                self.handleInitialLoad(stats: stats)
            case let .failure(status):
                self.handleInitialLoadError(status)
            }
        }
    }

    func reloadStats() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchStats { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case let .success(stats):
                self.handleStatsReload(with: stats)
            case let .failure(status):
                self.handleStatsError(status)
            }
        }
    }

    func didSelectSavedSearchResult(withName name: String) {
        guard let searchResult = userDefaults.lastSearchResult.first(where: { $0.name == name }) else {
            assertionFailure("Search result not found: \(name)")
            return
        }
        delegate?.presentVaccinationCentres(for: searchResult)
    }

    func didSelect(_ location: LocationSearchResult) {
        handleLastSelectedSearchResult()
        delegate?.presentVaccinationCentres(for: location)
    }
}
