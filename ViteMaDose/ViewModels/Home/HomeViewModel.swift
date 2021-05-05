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
    func updateLastSelectedDepartmentIfNeeded(_ code: String?)
    func didSelectLastDepartment()
    func didSelect(_ department: Department)

    var departments: Departments { get }
    var stats: Stats? { get }
}

protocol HomeViewModelDelegate: AnyObject {
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)

    func presentVaccinationCentres(for department: Department)
    func presentInitialLoadError(_ error: Error)
    func presentFetchStatsError(_ error: Error)

    func reloadTableView(with headingCells: [HomeCell], andStatsCells statsCells: [HomeCell])
}

class HomeViewModel {
    private let apiService: BaseAPIServiceProvider
    private let userDefaults: UserDefaults
    weak var delegate: HomeViewModelDelegate?

    var departments: Departments = []
    var stats: Stats?

    private var isLoading = false {
        didSet {
            let isEmpty = departments.isEmpty && stats == nil
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: isEmpty)
        }
    }

    private var headingCells: [HomeCell] = []
    private var statsCell: [HomeCell] = []

    private(set) var lastSelectedDepartmentCode: String?

    // MARK: init

    required init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        userDefaults: UserDefaults = .shared
    ) {
        self.apiService = apiService
        self.userDefaults = userDefaults
    }

    // MARK: Handle API result

    private func handleInitialLoad(departments: Departments, stats: Stats) {
        self.departments = departments
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

    private func handleLastSelectedDepartmentUpdate() {
        updateHeadingCells()
        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell)
    }

    private func updateHeadingCells() {
        let titleCellViewData = HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText)
        let departmentSelectionViewData = HomeDepartmentSelectionViewData()
        let lastSelectedDepartmentViewData = getLastSelectedDepartmentCellViewData()

        headingCells = [
            .title(titleCellViewData),
            .departmentSelection(departmentSelectionViewData)
        ]

        if let viewData = lastSelectedDepartmentViewData {
            headingCells.append(.department(viewData))
        }
    }

    private func updateStatsCells() {
        guard let departmentsStats = stats?[StatsKey.allDepartments.rawValue] else {
            return
        }

        let statsTitleViewModel = HomeTitleCellViewData(titleText: HomeTitleCell.lastStatsAttributedText, topMargin: 15, bottomMargin: 5)
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

    private func getLastSelectedDepartmentCellViewData() -> HomeDepartmentCellViewData? {
        guard
            let lastSelectedDepartmentCode = userDefaults.lastSelectedDepartmentCode,
            let department = departments.first(where: { $0.codeDepartement == lastSelectedDepartmentCode}),
            let name = department.nomDepartement,
            let code = department.codeDepartement
        else {
            return nil
        }

        return HomeDepartmentCellViewData(
            titleText: Localization.Home.recent_search,
            name: name,
            code: code
        )
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
    // TODO: Concurrent calls
    func load() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchDepartments { [weak self] result in
            switch result {
            case let .success(departments):
                self?.apiService.fetchStats { result in
                    switch result {
                    case let .success(stats):
                        self?.handleInitialLoad(departments: departments, stats: stats)
                        self?.isLoading = false
                    case let .failure(status):
                        self?.handleInitialLoadError(status)
                        self?.isLoading = false
                    }
                }
            case let .failure(status):
                self?.handleInitialLoadError(status)
                self?.isLoading = false
            }
        }
    }

    func reloadStats() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchStats { [weak self] result in
            self?.isLoading = false

            switch result {
            case let .success(stats):
                self?.handleStatsReload(with: stats)
            case let .failure(status):
                self?.handleStatsError(status)
            }
        }
    }

    func updateLastSelectedDepartmentIfNeeded(_ code: String?) {
        guard code != lastSelectedDepartmentCode else {
            return
        }
        lastSelectedDepartmentCode = code
        handleLastSelectedDepartmentUpdate()
    }

    func didSelectLastDepartment() {
        guard
            let code = userDefaults.lastSelectedDepartmentCode,
            let department = departments.first(where: { $0.codeDepartement == code})
        else {
            return
        }
        delegate?.presentVaccinationCentres(for: department)
    }

    func didSelect(_ department: Department) {
        delegate?.presentVaccinationCentres(for: department)
    }
}
