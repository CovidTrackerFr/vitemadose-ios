//
//  HomeViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

protocol HomeViewModelProvider {
    func fetchCounties()
    func cellViewModel(at indexPath: IndexPath) -> VaccinationCentre?
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

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading)
        }
    }

    var numberOfRows: Int {
        0
    }

    var counties: Counties {
        return allCounties
    }

    func cellViewModel(at indexPath: IndexPath) -> VaccinationCentre? {
        nil
    }

    // MARK: init

    required init(apiService: APIServiceProvider = APIService()) {
        self.apiService = apiService
    }

    deinit {
        apiService.cancelRequest()
    }

    // MARK: Handle API result

    private func didFetchCounties(_ counties: Counties) {
        allCounties = counties
    }

    private func handleError(_ error: APIEndpoint.APIError) {
        delegate?.displayError(withMessage: error.localizedDescription)
    }
}

// MARK: - HomeViewModelProvider

extension HomeViewModel: HomeViewModelProvider {
    public func fetchCounties() {
        guard !isLoading else { return }
        isLoading = true

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
}
