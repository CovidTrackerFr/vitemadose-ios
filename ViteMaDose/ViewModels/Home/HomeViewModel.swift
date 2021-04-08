//
//  HomeViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

protocol HomeViewModelProvider {
	func fetchVaccinationCentre(for county: County)
	func cellViewModel(at indexPath: IndexPath) -> VaccinationCentre?
	func bookingLink(at indexPath: IndexPath) -> URL?
	var numberOfRows: Int { get }
}

protocol HomeViewModelDelegate: class {
    func countySelected(_ county: County)
	func updateLoadingState(isLoading: Bool)
	func reloadTableView(isEmpty: Bool)
	func displayError(withMessage message: String)
}

class HomeViewModel {
	private let apiService: APIServiceProvider
	weak var delegate: HomeViewModelDelegate?

	private var allVaccinationCentres: [VaccinationCentre] = []

	private var isLoading = false {
		didSet {
			delegate?.updateLoadingState(isLoading: isLoading)
		}
	}

	var numberOfRows: Int {
		allVaccinationCentres.count
	}

	func cellViewModel(at indexPath: IndexPath) -> VaccinationCentre? {
		self.allVaccinationCentres[safe: indexPath.row]
	}

	func bookingLink(at indexPath: IndexPath) -> URL? {
		if let bookingUrlString = self.allVaccinationCentres[safe: indexPath.row]?.url {
			return URL(string: bookingUrlString)
		} else {
			return nil
		}
	}

	// MARK: init

	required init(apiService: APIServiceProvider = APIService()) {
		self.apiService = apiService
	}

	deinit {
		apiService.cancelRequest()
	}

	// MARK: Handle API result

	private func didFetchVaccinationCentres(_ vaccinationCentres: VaccinationCentres) {
		let isEmpty = vaccinationCentres.centresDisponibles.isEmpty && vaccinationCentres.centresIndisponibles.isEmpty
		allVaccinationCentres = vaccinationCentres.centresDisponibles + vaccinationCentres.centresIndisponibles
		delegate?.reloadTableView(isEmpty: isEmpty)
	}

	private func handleError(_ error: APIEndpoint.APIError) {
		delegate?.displayError(withMessage: error.localizedDescription)
	}
}

// MARK: - HomeViewModelProvider

extension HomeViewModel: HomeViewModelProvider {
	public func fetchVaccinationCentre(for county: County) {
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
