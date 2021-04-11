//
//  CountySelectionViewModel.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation

protocol CountyCellViewModelProvider {
    var countyName: String { get }
    var countyCode: String { get }
}

struct CountyCellViewModel: CountyCellViewModelProvider {
    var countyName: String
    var countyCode: String
}

protocol CountySelectionViewModelProvider {
    var numberOfRows: Int { get }
    func cellViewModel(at indexPath: IndexPath) -> CountyCellViewModel?
    func county(at indexPath: IndexPath) -> County?
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

    func cellViewModel(at indexPath: IndexPath) -> CountyCellViewModel? {
        guard let county = allCounties[safe: indexPath.row] else {
            assertionFailure("No county found at IndexPath \(indexPath)")
            return nil
        }

        guard let countyName = county.nomDepartement,
              let countyCode = county.codeDepartement
        else {
            return nil
        }

        return CountyCellViewModel(
            countyName: countyName,
            countyCode: String(countyCode)
        )
    }

    func county(at indexPath: IndexPath) -> County? {
        return allCounties[safe: indexPath.row]
    }
}
