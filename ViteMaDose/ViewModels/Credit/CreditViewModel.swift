//
//  CreditViewModel.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import Foundation

protocol CreditViewModelProvider {
    var numberOfSections: Int { get }
    func numberOfRows(in section: Int) -> Int
    func cellViewModel(at indexPath: IndexPath) -> CreditCellViewDataProvider?
    func didSelectCell(at indexPath: IndexPath)
}

protocol CreditViewModelDelegate: AnyObject {
    func reloadTableView(with credits: [Credit])
    func openURL(url: URL)

    func updateLoadingState(isLoading: Bool, isEmpty: Bool)
    func presentLoadError(_ error: Error)
}

class CreditViewModel: CreditViewModelProvider {
    private let apiService: BaseAPIServiceProvider
    weak var delegate: CreditViewModelDelegate?

    private var allCredits: [Credit] = []
    private var isLoading = false {
        didSet {
            let isEmpty = allCredits.count == 0
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: isEmpty)
        }
    }

    var numberOfSections: Int {
        1
    }

    func numberOfRows(in section: Int) -> Int {
        allCredits.count
    }

    // MARK: init

    required init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        credits: [Credit]
    ) {
        self.apiService = apiService
        self.allCredits = credits

        delegate?.reloadTableView(with: credits)
    }

    func cellViewModel(at indexPath: IndexPath) -> CreditCellViewDataProvider? {
        guard let credit = allCredits[safe: indexPath.row] else {
            assertionFailure("No credit found at IndexPath \(indexPath)")
            return nil
        }

        return CreditCellViewData(
            creditName: credit.shownName,
            creditRole: credit.shownRole,
            creditImage: credit.photo
        )
    }

    func didSelectCell(at indexPath: IndexPath) {
        guard let credit = allCredits[safe: indexPath.row] else {
            assertionFailure("Credit not found at indexPath \(indexPath)")
            return
        }

        if let detailsURL = credit.site_web ?? credit.links?.first?.url, let url = URL(string: detailsURL) {
            delegate?.openURL(url: url)
        }
    }

    private func handleLoad(with credits: [Credit]) {
        self.allCredits = credits

        delegate?.reloadTableView(with: credits)
    }

    private func handleError(_ error: Error) {
        delegate?.presentLoadError(error)
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchCredits { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case let .success(credits):
                self.handleLoad(with: credits.contributors ?? [])
            case let .failure(status):
                self.handleError(status)
            }
        }
    }
}
