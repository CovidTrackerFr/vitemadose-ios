// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
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
    case searchBar(HomeSearchBarCellViewData)
    case searchResult(HomeSearchResultCellViewData)
    case stats(HomeCellStatsViewData)
    case followedCentre
}

// MARK: - Home ViewModel

protocol HomeViewModelProvider {
    var stats: Stats? { get }
    var delegate: HomeViewModelDelegate? { get }

    func load()
    func reloadHeadingCellsIfNeeded()
    func didSelectSavedSearchResult(withName name: String)
    func didSelect(_ location: LocationSearchResult)
    func displayAppOnboardingIfNeeded()
}

protocol HomeViewModelDelegate: AnyObject {
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)
    func presentVaccinationCentres(for location: LocationSearchResult)
    func presentFetchStatsError(_ error: Error)
    func presentOnboarding()
    func reloadTableView(with headingCells: [HomeCell], andStatsCells statsCells: [HomeCell], animated: Bool)
}

final class HomeViewModel {
    private let apiService: BaseAPIServiceProvider
    private let userDefaults: UserDefaults
    private let notificationCenter: UNUserNotificationCenter

    weak var delegate: HomeViewModelDelegate?
    var stats: Stats?

    private var isLoading = false {
        didSet {
            let isEmpty = stats == nil
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: isEmpty)
        }
    }

    private var headingCells: [HomeCell] = []
    private var statsCell: [HomeCell] = []
    private lazy var hasFollowedCentresLastSate = userDefaults.hasFollowedCentres

    // MARK: init

    required init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        userDefaults: UserDefaults = .shared,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.apiService = apiService
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
    }

    // MARK: Handle API result

    private func handleStatsLoad(stats: Stats) {
        self.stats = stats

        updateHeadingCells()
        updateStatsCells()

        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell, animated: false)
    }

    private func handleLastSelectedSearchResult() {
        updateHeadingCells()
        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell, animated: true)
    }

    private func updateHeadingCells() {
        let titleCellViewData = HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText, bottomMargin: 0)
        let departmentSelectionViewData = HomeSearchBarCellViewData()
        let lastSelectedDepartmentViewData = getRecentSearchResultsViewData()

        headingCells = [
            .title(titleCellViewData),
            .searchBar(departmentSelectionViewData)
        ]
        if userDefaults.hasFollowedCentres {
            headingCells.append(.followedCentre)
        }

        headingCells.append(contentsOf: lastSelectedDepartmentViewData.map(HomeCell.searchResult))
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

    private func getRecentSearchResultsViewData() -> [HomeSearchResultCellViewData] {
        let lastSearchResults = userDefaults.lastSearchResults
        return lastSearchResults.enumerated().map { index, location in
            HomeSearchResultCellViewData(
                titleText: index == 0 ? Localization.Home.recent_search.format(lastSearchResults.count) : nil,
                name: location.formattedName,
                postCode: location.postCode,
                departmentCode: location.selectedDepartmentCode
            )
        }
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
                self.handleStatsLoad(stats: stats)
            case let .failure(status):
                self.handleStatsError(status)
            }
        }
    }

    func reloadHeadingCellsIfNeeded() {
        let hasFollowedCentres = userDefaults.hasFollowedCentres
        if hasFollowedCentresLastSate == hasFollowedCentres {
            hasFollowedCentresLastSate = hasFollowedCentres
            return
        }

        updateHeadingCells()
        hasFollowedCentresLastSate = hasFollowedCentres

        delegate?.reloadTableView(with: headingCells, andStatsCells: statsCell, animated: true)
    }

    func didSelectSavedSearchResult(withName name: String) {
        let predicate: (LocationSearchResult) -> Bool = { $0.formattedName == name }
        let foundSearchResult = userDefaults.lastSearchResults.first(where: predicate)
        guard let searchResult = foundSearchResult else {
            assertionFailure("Search result not found: \(name)")
            return
        }
        delegate?.presentVaccinationCentres(for: searchResult)
    }

    func didSelect(_ location: LocationSearchResult) {
        handleLastSelectedSearchResult()
        delegate?.presentVaccinationCentres(for: location)
    }

    func displayAppOnboardingIfNeeded() {
        guard !userDefaults.didPresentAppOnboarding else {
            return
        }
        userDefaults.didPresentAppOnboarding = true
        delegate?.presentOnboarding()
    }
}
