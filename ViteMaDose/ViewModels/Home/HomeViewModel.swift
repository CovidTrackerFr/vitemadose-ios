//
//  HomeViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit
import APIRequest

// MARK: - Home Cell ViewModel

enum HomeSection: CaseIterable {
    case heading
    case stats
}

enum HomeCell: Hashable {
    case title(HomeTitleCellViewData)
    case countySelection(HomeCountySelectionViewData)
    case county(HomeCountyCellViewData)
    case stats(HomeCellStatsViewData)
}

// MARK: - Home ViewModel

protocol HomeViewModelProvider {
    func load()
    func reloadStats()
    func updateLastSelectedCountyIfNeeded(_ code: String?)
    func didSelectLastCounty(_ indexPath: IndexPath)
    func didSelect(_ county: County)

    var counties: Counties { get }
    var stats: Stats? { get }
}

protocol HomeViewModelDelegate: class {
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)

    func presentVaccinationCentres(for county: County)
    func presentInitialLoadError(_ error: Error)
    func presentFetchStatsError(_ error: Error)

    func reloadTableView(with headingCells: [HomeCell], andStatsCells: [HomeCell])
    func reloadHeadingSection(with headingCells: [HomeCell])
    func reloadStatsSection(with statsCells: [HomeCell])
}

class HomeViewModel {
    private let apiService: APIServiceProvider
    weak var delegate: HomeViewModelDelegate?

    var counties: Counties = []
    var stats: Stats?

    private var isLoading = false {
        didSet {
            let isEmpty = counties.isEmpty && stats == nil
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: isEmpty)
        }
    }

    private var headingCells: [HomeCell] = []
    private var statsCell: [HomeCell] = []

    private var lastSelectedCountyCode: String?

    // MARK: init

    required init(apiService: APIServiceProvider = APIService()) {
        self.apiService = apiService
    }

    // MARK: Handle API result

    private func handleInitialLoad(counties: Counties, stats: Stats) {
        self.counties = counties
        self.stats = stats

        updateHeadingCells()
        updateStatsCells()

        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell)
    }

    private func handleStatsReload(with stats: Stats) {
        self.stats = stats
        updateStatsCells()
        delegate?.reloadStatsSection(with: statsCell)
    }

    private func handleLastSelectedCountyUpdate() {
        updateHeadingCells()
        delegate?.reloadHeadingSection(with: headingCells)
    }

    private func updateHeadingCells() {
        let titleCellViewData = HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText)
        let countySelectionViewData = HomeCountySelectionViewData()
        let lastSelectedCountyViewData = getLastSelectedCountyCellsViewData()

        headingCells = [
            .title(titleCellViewData),
            .countySelection(countySelectionViewData)
        ]

        if let viewData = lastSelectedCountyViewData {
            for element in viewData {
                headingCells.append(.county(element))
            }
        }
    }

    private func updateStatsCells() {
        guard let allCountiesStats = stats?[StatsKey.allCounties.rawValue] else {
            return
        }

        let statsTitleViewModel = HomeTitleCellViewData(titleText: HomeTitleCell.lastStatsAttributedText, topMargin: 15, bottomMargin: 5)
        let allCentresViewModel = HomeCellStatsViewData(.allCentres(allCountiesStats.total))
        let centresWithAvailabilitiesViewModel = HomeCellStatsViewData(.centresWithAvailabilities(allCountiesStats.disponibles))
        let allAvailabilitiesViewModel = HomeCellStatsViewData(.allAvailabilities(allCountiesStats.creneaux))
        let percentageAvailabilitiesViewModel = HomeCellStatsViewData(.percentageAvailabilities(allCountiesStats.pourcentage))
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

    private func getLastSelectedCountyCellsViewData() -> [HomeCountyCellViewData]? {

        var countyCellsViewData = [HomeCountyCellViewData]()

        for index in UserDefaults.lastSelectedCountyCodes {

            let county = counties.first(where: { index == $0.codeDepartement })

            if
                let county = county,
                let countyName = county.nomDepartement,
                let countyCode = county.codeDepartement
            {
                countyCellsViewData.append(HomeCountyCellViewData(
                    titleText: countyCellsViewData.isEmpty ? Localization.Home.recent_searches : nil,
                    countyName: countyName,
                    countyCode: countyCode
                ))
            }
        }

        if !countyCellsViewData.isEmpty {
            return countyCellsViewData
        } else {
            return nil
        }
    }

    private func handleInitialLoadError(_ error: APIResponseStatus) {
        delegate?.presentInitialLoadError(error)
    }

    private func handleStatsError(_ error: APIResponseStatus) {
        delegate?.presentFetchStatsError(error)
    }
}

// MARK: - HomeViewModelProvider

extension HomeViewModel: HomeViewModelProvider {
    // TODO: Concurrent calls
    func load() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchCounties { [weak self] data, status in
            if let counties = data {
                self?.apiService.fetchStats { data, status in
                    if let stats = data {
                        self?.handleInitialLoad(counties: counties, stats: stats)
                        self?.isLoading = false
                    } else {
                        self?.handleInitialLoadError(status)
                        self?.isLoading = false
                    }
                }
            } else {
                self?.handleInitialLoadError(status)
                self?.isLoading = false
            }
        }
    }

    func reloadStats() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchStats { [weak self] data, status in
            self?.isLoading = false

            if let stats = data {
                self?.handleStatsReload(with: stats)
            } else {
                self?.handleStatsError(status)
            }
        }
    }

    func updateLastSelectedCountyIfNeeded(_ code: String?) {
        guard code != lastSelectedCountyCode else {
            return
        }
        lastSelectedCountyCode = code
        handleLastSelectedCountyUpdate()
    }

    func didSelectLastCounty(_ indexPath: IndexPath) {
        let row = indexPath.row - 2
        guard
            let countyCode = UserDefaults.lastSelectedCountyCodes[safe:row],
            let county = counties.first(where: { countyCode == $0.codeDepartement })
        else {
            return
        }
        delegate?.presentVaccinationCentres(for: county)
    }

    func didSelect(_ county: County) {
        delegate?.presentVaccinationCentres(for: county)
    }
}
