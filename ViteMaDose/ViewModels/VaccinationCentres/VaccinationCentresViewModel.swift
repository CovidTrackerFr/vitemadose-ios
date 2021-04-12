//
//  VaccinationCentresViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import Foundation

// TODO: View Model

//class VaccinationCentresViewModel {
//    private var allVaccinationCentres: [VaccinationCentre] = []
//
//    func bookingLink(at indexPath: IndexPath) -> URL? {
//        if let bookingUrlString = allVaccinationCentres[safe: indexPath.row]?.url {
//            return URL(string: bookingUrlString)
//        } else {
//            return nil
//        }
//    }
//
//    private func didFetchVaccinationCentres(_ vaccinationCentres: VaccinationCentres) {
//        let isEmpty = vaccinationCentres.centresDisponibles.isEmpty && vaccinationCentres.centresIndisponibles.isEmpty
//        allVaccinationCentres = vaccinationCentres.centresDisponibles + vaccinationCentres.centresIndisponibles
//        delegate?.reloadTableView(isEmpty: isEmpty)
//    }
//
//    public func fetchVaccinationCentre(for county: County) {
//        guard !isLoading else { return }
//        isLoading = true
//
//        guard let countyCode = county.codeDepartement else {
//            delegate?.displayError(withMessage: "County code missing")
//            return
//        }
//
//        let vaccinationCentresEndpoint = APIEndpoint.vaccinationCentres(county: countyCode)
//
//        apiService.fetchVaccinationCentres(vaccinationCentresEndpoint) { [weak self] result in
//            self?.isLoading = false
//
//            switch result {
//                case let .success(vaccinationCentres):
//                    self?.didFetchVaccinationCentres(vaccinationCentres)
//                case .failure(let error):
//                    self?.handleError(error)
//            }
//        }
//    }
//}
