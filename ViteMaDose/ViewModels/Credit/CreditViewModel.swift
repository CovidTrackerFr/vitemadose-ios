//
//  CreditViewModel.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import Foundation

protocol CreditViewModelProvider {
    var numberOfRows: Int { get }
    func cellViewModel(at indexPath: IndexPath) -> CreditCellViewDataProvider?
    func didSelectCell(at indexPath: IndexPath)
}

protocol CreditViewModelDelegate: class {
    func reloadTableView(with credits: Credits)
    func dismissViewController(with credit: Credit)
}

class CreditViewModel: CreditViewModelProvider {
    private let apiService: APIServiceProvider
    weak var delegate: CreditViewModelDelegate?

    private var allCredits: [Credit] = []

    var numberOfRows: Int {
        allCredits.count
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

    func cellViewModel(at indexPath: IndexPath) -> CreditCellViewDataProvider? {
        guard let credit = allCredits[safe: indexPath.row] else {
            assertionFailure("No credit found at IndexPath \(indexPath)")
            return nil
        }

        guard let nom = credit.nom,
              let image = credit.image
        else {
            return nil
        }

        return CreditCellViewData(
            creditName: nom,
            creditImage: image
        )
    }

    func didSelectCell(at indexPath: IndexPath) {
        guard let credit = allCredits[safe: indexPath.row] else {
            assertionFailure("Credit not found at indexPath \(indexPath)")
            return
        }

        delegate?.dismissViewController(with: credit)
    }
}
