//
//  VaccinationCentresViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import Foundation


protocol VaccinationCentresViewModelProvider {
    var county: County { get }
    var numberOfRows: Int { get }
    func fetchVaccinationCentres()
    func cellViewModel(at indexPath: IndexPath) -> String?
    func bookingLink(at indexPath: IndexPath) -> URL?
}

protocol VaccinationCentresViewModelDelegate: class {
    func reloadTableView(isEmpty: Bool)
    func updateLoadingState(isLoading: Bool)
    func displayError(withMessage message: String)
}

class VaccinationCentresViewModel: VaccinationCentresViewModelProvider {
    private let apiService: APIService
    private var allVaccinationCentres: [VaccinationCentre] = []
    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading)
        }
    }

    var county: County
    weak var delegate: VaccinationCentresViewModelDelegate?

    var numberOfRows: Int {
        return allVaccinationCentres.count
    }

    init(apiService: APIService = APIService(), county: County) {
        self.apiService = apiService
        self.county = county
    }

    func cellViewModel(at indexPath: IndexPath) -> String? {
        return allVaccinationCentres[safe: indexPath.row]?.nom
    }

    func bookingLink(at indexPath: IndexPath) -> URL? {
        if let bookingUrlString = allVaccinationCentres[safe: indexPath.row]?.url {
            return URL(string: bookingUrlString)
        } else {
            return nil
        }
    }

    private func didFetchVaccinationCentres(_ vaccinationCentres: VaccinationCentres) {
        let isEmpty = vaccinationCentres.centresDisponibles.isEmpty && vaccinationCentres.centresIndisponibles.isEmpty
        allVaccinationCentres = vaccinationCentres.centresDisponibles + vaccinationCentres.centresIndisponibles
        delegate?.reloadTableView(isEmpty: isEmpty)
    }

    private func handleError(_ error: APIEndpoint.APIError) {

    }

    public func fetchVaccinationCentres() {
        guard !isLoading else { return }
        isLoading = true

        guard let countyCode = county.codeDepartement else {
            delegate?.displayError(withMessage: "County code missing")
            return
        }

        let vaccinationCentresEndpoint = APIEndpoint.vaccinationCentres(county: countyCode)

        apiService.fetchVaccinationCentres(vaccinationCentresEndpoint) { [weak self] result in
            self?.isLoading = false

            switch result {
                case let .success(vaccinationCentres):
                    self?.didFetchVaccinationCentres(vaccinationCentres)
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }
}
