//
//  CountySelectionViewModel.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation

protocol CountySelectionViewModelProvider {
    func cellViewModel(at indexPath: IndexPath) -> County?
    var numberOfRows: Int { get }
}

protocol CountySelectionViewModelDelegate: class {
    func reloadTableView(with counties: Counties)
}

class CountySelectionViewModel: CountySelectionViewModelProvider {
    private let apiService: APIServiceProvider
    weak var delegate: CountySelectionViewModelDelegate?

    private var allCounties: [County] = []

    var numberOfRows: Int {
        allCounties.count
    }

    func cellViewModel(at indexPath: IndexPath) -> County? {
        self.allCounties[safe: indexPath.row]
    }

    // MARK: init

    required init(
        apiService: APIServiceProvider = APIService(),
        counties: Counties
    ) {
        self.apiService = apiService
        self.allCounties = counties
    }

    deinit {
        apiService.cancelRequest()
    }
}
