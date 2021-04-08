//
//  CountySelectionViewModel.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation

protocol CountySelectionViewModelProvider {
    func fetchCounties()
    func cellViewModel(at indexPath: IndexPath) -> County?
    var numberOfRows: Int { get }
}

protocol CountySelectionViewModelDelegate: class {
    func updateLoadingState(isLoading: Bool)
    func reloadTableView(with counties: Counties)
    func displayError(withMessage message: String)
}

class CountySelectionViewModel {
    private let apiService: APIServiceProvider
    weak var delegate: CountySelectionViewModelDelegate?

    private var allCounties: [County] = []

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading)
        }
    }

    var numberOfRows: Int {
        allCounties.count
    }

    func cellViewModel(at indexPath: IndexPath) -> County? {
        self.allCounties[safe: indexPath.row]
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
        delegate?.reloadTableView(with: counties)
    }

    private func handleError(_ error: APIEndpoint.APIError) {
        delegate?.displayError(withMessage: error.localizedDescription)
    }
}

// MARK: - HomeViewModelProvider

extension CountySelectionViewModel: CountySelectionViewModelProvider {
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
