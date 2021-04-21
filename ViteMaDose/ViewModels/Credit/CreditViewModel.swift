//
//  CreditViewModel.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import Foundation
import APIRequest

protocol CreditViewModelProvider {
    var numberOfSections: Int { get }
    func numberOfRows(in section: Int) -> Int
    func cellViewModel(at indexPath: IndexPath) -> CreditCellViewDataProvider?
    func didSelectCell(at indexPath: IndexPath)
}

protocol CreditViewModelDelegate: class {
    func reloadTableView(with credits: Credits)
    func openURL(url: URL)
    
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)
    func presentLoadError(_ error: Error)
}

class CreditViewModel: CreditViewModelProvider {
    private let apiService: APIServiceProvider
    weak var delegate: CreditViewModelDelegate?

    private var allCredits: Credits = []
    private var isLoading = false {
        didSet {
            let isEmpty = allCredits.count == 0
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: isEmpty)
        }
    }

    var numberOfSections: Int {
        allCredits.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        (allCredits[section].users?.count ?? 0) + 1
    }

    // MARK: init

    required init(
        apiService: APIServiceProvider = APIService(),
        credits: Credits
    ) {
        self.apiService = apiService
        self.allCredits = credits

        delegate?.reloadTableView(with: credits)
    }
    
    func sectionViewModel(at section: Int) -> CreditSectionViewDataProvider? {
        guard let sectionModel = allCredits[safe: section] else {
            assertionFailure("No section found at section \(section)")
            return nil
        }

        guard let title = sectionModel.section
        else {
            return nil
        }

        return CreditSectionViewData(
            title: title
        )
    }

    func cellViewModel(at indexPath: IndexPath) -> CreditCellViewDataProvider? {
        guard let credit = allCredits[safe: indexPath.section]?.users?[safe: indexPath.row - 1] else {
            assertionFailure("No credit found at IndexPath \(indexPath)")
            return nil
        }

        guard let nom = credit.nom,
              let role = credit.role,
              let image = credit.image
        else {
            return nil
        }

        return CreditCellViewData(
            creditName: nom,
            creditRole: role,
            creditImage: image
        )
    }

    func didSelectCell(at indexPath: IndexPath) {
        guard let credit = allCredits[safe: indexPath.section]?.users?[safe: indexPath.row - 1] else {
            assertionFailure("Credit not found at indexPath \(indexPath)")
            return
        }

        if let detailsURL = credit.detailsURL, let url = URL(string: detailsURL) {
            delegate?.openURL(url: url)
        }
    }
    
    private func handleLoad(with credits: Credits) {
        self.allCredits = credits

        delegate?.reloadTableView(with: credits)
    }
    
    private func handleError(_ error: APIResponseStatus) {
        delegate?.presentLoadError(error)
    }
    
    func load() {
        guard !isLoading else { return }
        isLoading = true

        apiService.fetchContributors { [weak self] data, status in
            self?.isLoading = false

            if let credits = data {
                self?.handleLoad(with: credits)
            } else {
                self?.handleError(status)
            }
        }
    }
}
