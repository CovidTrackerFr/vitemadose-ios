//
//  HomeViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

// MARK: - Home Cell ViewModel

enum HomeCellType {
    case stats
    case logos
}

protocol HomeCellViewModelProvider {
    var cellType: HomeCellType { get }
}

protocol HomeCellProvider {
    func configure(with viewModel: HomeCellViewModelProvider)
}

// MARK: - Home ViewModel

protocol HomeViewModelProvider {
    func fetchCounties()
    func fetchStats()
    func cellViewModel(at indexPath: IndexPath) -> HomeCellViewModelProvider?
    var numberOfRows: Int { get }
    var counties: Counties { get }
}

protocol HomeViewModelDelegate: class {
    func updateLoadingState(isLoading: Bool)
    func reloadTableView(isEmpty: Bool)
    func displayError(withMessage message: String)
}

class HomeViewModel {
    private let apiService: APIServiceProvider
    weak var delegate: HomeViewModelDelegate?

    private var allCounties: Counties = []
    private var cellViewModels: [HomeCellViewModelProvider] = []

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading)
        }
    }

    var numberOfRows: Int {
        cellViewModels.count
    }

    var counties: Counties {
        return allCounties
    }

    func cellViewModel(at indexPath: IndexPath) -> HomeCellViewModelProvider? {
        return cellViewModels[safe: indexPath.row]
    }

    // MARK: init

    required init(apiService: APIServiceProvider = APIService()) {
        self.apiService = apiService
    }

    // MARK: Handle API result

    private func didFetchCounties(_ counties: Counties) {
        allCounties = counties
    }

    private func didFetchStats(_ stats: Stats) {
        cellViewModels.removeAll()

        if let allCountiesStats = stats[StatsKey.allCounties.rawValue] {
            let statsViewModels = [
                HomeCellStatsViewModel(
                    cellType: .stats,
                    viewData: HomeStatsTableViewCell.ViewData(.allCentres(allCountiesStats.total))
                ),
                HomeCellStatsViewModel(
                    cellType: .stats,
                    viewData: HomeStatsTableViewCell.ViewData(.centresWithAvailabilities(allCountiesStats.disponibles))
                ),
                HomeCellStatsViewModel(
                    cellType: .stats,
                    viewData: HomeStatsTableViewCell.ViewData(.allAvailabilities(allCountiesStats.creneaux))
                ),
                HomeCellStatsViewModel(
                    cellType: .stats,
                    viewData: HomeStatsTableViewCell.ViewData(.externalMap)
                )
            ]
            cellViewModels.append(contentsOf: statsViewModels)
        }

        cellViewModels.append(HomeCellPartnersViewModel(cellType: .logos))
        delegate?.reloadTableView(isEmpty: cellViewModels.isEmpty)
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
            self?.isLoading = false
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
}
