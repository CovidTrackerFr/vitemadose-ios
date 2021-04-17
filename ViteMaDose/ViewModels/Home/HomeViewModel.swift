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
    func fetchCounties()
    func fetchStats()
    func updateLastSelectedIfNeededCounty(_ code: String?)
    func didSelectLastCounty()
    func didSelect(_ county: County)
    var counties: Counties { get }
    var stats: Stats? { get }
}

protocol HomeViewModelDelegate: class {
    func updateLoadingState(isLoading: Bool)
    func showVaccinationCentres(for county: County)
    func displayError(withMessage message: String)
    func loadTableView(with headingCells: [HomeCell], andStatsCells: [HomeCell])
    func updateHeadingSection(with cell: HomeCell)
}

class HomeViewModel {
    private let apiService: APIServiceProvider
    weak var delegate: HomeViewModelDelegate?

    var counties: Counties = []
    var stats: Stats?

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading)
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

    private func didFetchCounties(_ counties: Counties) {
        self.counties = counties
        updateHeadingCells()
    }

    private func didFetchStats(_ stats: Stats) {
        self.stats = stats
        updateStatsCells()
    }

    private func updateHeadingCells() {
        let titleCellViewData = HomeTitleCellViewData(titleText: mainTitleAttributedText)
        let countySelectionViewData = HomeCountySelectionViewData()
        var lastSelectedCountyViewData: HomeCountyCellViewData?

        if
            let countyCode = UserDefaults.lastSelectedCountyCode,
            let county = counties.first(where: { $0.codeDepartement == countyCode})
        {
            guard
                let countyName = county.nomDepartement,
                let countyCode = county.codeDepartement
            else {
                return
            }

            lastSelectedCountyViewData = HomeCountyCellViewData(
                titleText: "Recherche Récente",
                countyName: countyName,
                countyCode: countyCode
            )
        }

        headingCells = [
            .title(titleCellViewData),
            .countySelection(countySelectionViewData)
        ]

        if let viewData = lastSelectedCountyViewData {
            headingCells.append(.county(viewData))
        }

        delegate?.loadTableView(with: headingCells, andStatsCells: statsCell)
    }

    private func updateStatsCells() {
        guard let allCountiesStats = stats?[StatsKey.allCounties.rawValue] else {
            return
        }

        let statsTitleViewModel = HomeTitleCellViewData(titleText: lastStatsAttributedText)
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

        delegate?.loadTableView(with: headingCells, andStatsCells: statsCell)
    }

    private func handleError(_ error: APIEndpoint.APIError) {
        delegate?.displayError(withMessage: error.localizedDescription)
    }
}

// MARK: - HomeViewModelProvider

extension HomeViewModel: HomeViewModelProvider {
    public func fetchCounties() {
        let countiesEndpoint = APIEndpoint.counties

        apiService.fetchCounties(countiesEndpoint) { [weak self] result in
            switch result {
                case let .success(counties):
                    self?.didFetchCounties(counties)
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }

    func fetchStats() {
        guard !isLoading else { return }
        isLoading = true

        let statsEndpoint = APIEndpoint.stats

        apiService.fetchStats(statsEndpoint) { [weak self] result in
            self?.isLoading = false

            switch result {
                case let .success(stats):
                    self?.didFetchStats(stats)
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }

    func updateLastSelectedIfNeededCounty(_ code: String?) {
        guard code != lastSelectedCountyCode else {
            return
        }
        lastSelectedCountyCode = code
        updateHeadingCells()
    }

    func didSelectLastCounty() {
        guard
            let countyCode = UserDefaults.lastSelectedCountyCode,
            let county = counties.first(where: { $0.codeDepartement == countyCode})
        else {
            return
        }
        delegate?.showVaccinationCentres(for: county)
    }

    func didSelect(_ county: County) {
        delegate?.showVaccinationCentres(for: county)
    }
}

extension HomeViewModel {
    private var mainTitleAttributedText: NSMutableAttributedString {
        let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)
        let titleText = "Trouvez une dose de vaccin facilement et rapidement"
        let titleFirstHighlightedText = "facilement"
        let titleSecondHighlightedText = "rapidement"

        let attributedText = NSMutableAttributedString(
            string: titleText,
            attributes: [
                NSAttributedString.Key.font: titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )

        attributedText.setColorForText(
            textForAttribute: titleFirstHighlightedText,
            withColor: .royalBlue
        )
        attributedText.setColorForText(
            textForAttribute: titleSecondHighlightedText,
            withColor: .mandy
        )

        return attributedText
    }

    private var lastStatsAttributedText: NSMutableAttributedString {
        let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)
        let titleText = "Dernières statistiques"

        return NSMutableAttributedString(
            string: titleText,
            attributes: [
                NSAttributedString.Key.font: titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )
    }
}
