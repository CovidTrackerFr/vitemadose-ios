//
//  VaccinationCentresViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import Foundation
import SwiftDate

protocol VaccinationCentresViewModelProvider {
    var county: County { get }
    var numberOfRows: Int { get }
    func fetchVaccinationCentres()
    func cellViewModel(at indexPath: IndexPath) -> VaccinationBookingCellViewModelProvider?
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

    func cellViewModel(at indexPath: IndexPath) -> VaccinationBookingCellViewModelProvider? {
        guard let vaccincationCentre = allVaccinationCentres[safe: indexPath.row] else {
            return nil
        }

        var url: URL?
        if let urlString = vaccincationCentre.url {
            url = URL(string: urlString)
        }

        var dosesText: String?
        if let dosesCount = vaccincationCentre.appointmentCount {
            dosesText = "\(String(dosesCount)) dose(s)"
        }

        let isAvailable = vaccincationCentre.prochainRdv != nil
        let date = vaccincationCentre.prochainRdv?.toDate()
        let dateString = date?.toString(.dateTimeMixed(dateStyle: .long, timeStyle: .short))

        var partnerLogo: UIImage?
        if let platform = vaccincationCentre.plateforme {
            partnerLogo =  PartnerLogo(rawValue: platform)?.image
        }

        let bookingButtonText = isAvailable ? "Prendre Rendez-Vous" : "Vérifier Ce Centre"
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(
            systemName: "arrow.up.right",
            withConfiguration:UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        )?.withTintColor(.white, renderingMode: .alwaysOriginal)

        let bookingButtonAttributedText = NSMutableAttributedString(
            string: bookingButtonText + " ",
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .semibold),
            ]
        )

        bookingButtonAttributedText.append(NSAttributedString(attachment: imageAttachment))

        return VaccinationBookingCellViewModel(
            dateText: isAvailable ? dateString ?? "Date Indisponible" : "Aucun rendez-vous disponible",
            addressNameText: vaccincationCentre.nom ?? "Nom du centre indisponible",
            addressText: vaccincationCentre.metadata?.address ?? "Addresse indisponible",
            phoneText: vaccincationCentre.metadata?.phoneNumber,
            bookingButtonText: bookingButtonAttributedText,
            vaccineTypesText: vaccincationCentre.vaccineType?.joined(separator: ", "),
            dosesText: dosesText,
            isAvailable: isAvailable,
            url: url,
            partnerLogo: partnerLogo
        )
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

private extension Date {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm E, d MMM y"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
}

