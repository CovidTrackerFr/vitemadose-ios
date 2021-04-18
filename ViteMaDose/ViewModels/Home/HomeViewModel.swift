//
//  HomeViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

// MARK: - Home Cell ViewModel

protocol HomeCellViewDataProvider { }

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
    func didSelectLastCounty()
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
        let lastSelectedCountyViewData = getLastSelectedCountyCellViewData()

        headingCells = [
            .title(titleCellViewData),
            .countySelection(countySelectionViewData)
        ]

        if let viewData = lastSelectedCountyViewData {
            headingCells.append(.county(viewData))
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
        let externalMapViewModel = HomeCellStatsViewData(.externalMap)

        statsCell = [
            .title(statsTitleViewModel),
            .stats(allCentresViewModel),
            .stats(centresWithAvailabilitiesViewModel),
            .stats(allAvailabilitiesViewModel),
            .stats(externalMapViewModel)
        ]
    }

    private func getLastSelectedCountyCellViewData() -> HomeCountyCellViewData? {
        guard
            let lastSelectedCountyCode = UserDefaults.lastSelectedCountyCode,
            let county = counties.first(where: { $0.codeDepartement == lastSelectedCountyCode}),
            let countyName = county.nomDepartement,
            let countyCode = county.codeDepartement
        else {
            return nil
        }

        return HomeCountyCellViewData(
            titleText: "Recherche Récente",
            countyName: countyName,
            countyCode: countyCode
        )
    }

    private func handleInitialLoadError(_ error: APIEndpoint.APIError) {
        delegate?.presentInitialLoadError(error)
    }

    private func handleStatsError(_ error: APIEndpoint.APIError) {
        delegate?.presentFetchStatsError(error)
    }
}

// MARK: - HomeViewModelProvider

extension HomeViewModel: HomeViewModelProvider {
    // TODO: Concurrent calls
    func load() {
        guard !isLoading else { return }
        isLoading = true

        fetchCounties { [weak self] countiesResult in
            switch countiesResult {
                case let .success(counties):
                    self?.fetchStats { statsResult in
                        switch statsResult {
                            case let .success(stats):
                                self?.handleInitialLoad(counties: counties, stats: stats)
                                self?.isLoading = false
                            case let .failure(error):
                                self?.handleInitialLoadError(error)
                                self?.isLoading = false
                        }
                    }
                case let .failure(error):
                    self?.handleInitialLoadError(error)
                    self?.isLoading = false
            }
        }
    }

    private func fetchCounties(completion: @escaping (Result<Counties, APIEndpoint.APIError>) -> ()) {
        let countiesEndpoint = APIEndpoint.counties

        apiService.fetchCounties(countiesEndpoint) { result in
            completion(result)
        }
    }

    private func fetchStats(completion: @escaping (Result<Stats, APIEndpoint.APIError>) -> ()) {
        let statsEndpoint = APIEndpoint.stats

        apiService.fetchStats(statsEndpoint) { result in
            completion(result)
        }
    }

    func reloadStats() {
        guard !isLoading else { return }
        isLoading = true

        let statsEndpoint = APIEndpoint.stats

        apiService.fetchStats(statsEndpoint) { [weak self] result in
            self?.isLoading = false

            switch result {
                case let .success(stats):
                    self?.handleStatsReload(with: stats)
                case .failure(let error):
                    self?.handleStatsError(error)
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

    func didSelectLastCounty() {
        guard
            let countyCode = UserDefaults.lastSelectedCountyCode,
            let county = counties.first(where: { $0.codeDepartement == countyCode})
        else {
            return
        }
        delegate?.presentVaccinationCentres(for: county)
    }

    func didSelect(_ county: County) {
        delegate?.presentVaccinationCentres(for: county)
    }
}
