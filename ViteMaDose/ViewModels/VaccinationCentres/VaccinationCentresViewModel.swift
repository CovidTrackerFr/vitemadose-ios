//
//  VaccinationCentresViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import Foundation
import SwiftDate
import UIKit
import PhoneNumberKit
import APIRequest

protocol VaccinationCentresViewModelProvider {
    var county: County { get }
    var numberOfRows: Int { get }
    func fetchVaccinationCentres()
    func cellViewModel(at indexPath: IndexPath) -> VaccinationBookingCellViewModelProvider?
    func bookingLink(at indexPath: IndexPath) -> URL?
}

protocol VaccinationCentresViewModelDelegate: class {
    func reloadTableViewHeader(with viewModel: VaccinationCentresHeaderViewModelProvider)
    func reloadTableView(isEmpty: Bool)
    func reloadTableViewFooter(with text: String?)
    func updateLoadingState(isLoading: Bool)
    func displayError(withMessage message: String)
}

class VaccinationCentresViewModel: VaccinationCentresViewModelProvider {
    private let apiService: APIServiceProvider
    private let phoneNumberKit = PhoneNumberKit()

    private var allVaccinationCentres: [VaccinationCentre] = []
    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading)
        }
    }

    private lazy var region = Region(
        calendar: Calendar.current,
        zone: Zones.current,
        locale: Locale(identifier: "fr_FR")
    )

    var county: County
    weak var delegate: VaccinationCentresViewModelDelegate?

    var numberOfRows: Int {
        return allVaccinationCentres.count
    }

    init(apiService: APIServiceProvider = APIService(), county: County) {
        self.apiService = apiService
        self.county = county
    }

    func cellViewModel(at indexPath: IndexPath) -> VaccinationBookingCellViewModelProvider? {
        guard let vaccinationCentre = allVaccinationCentres[safe: indexPath.row] else {
            return nil
        }

        var url: URL?
        if let urlString = vaccinationCentre.url {
            url = URL(string: urlString)
        }

        let isAvailable = vaccinationCentre.prochainRdv != nil

        var dayString: String?
        var timeString: String?

        if
            let dateString = vaccinationCentre.prochainRdv,
            let date = dateString.toDate(nil, region: region)
        {
            dayString = date.toString(.date(.long))
            timeString = date.toString(.time(.short))
        }

        var partnerLogo: UIImage?
        if let platform = vaccinationCentre.plateforme {
            partnerLogo =  PartnerLogo(rawValue: platform)?.image
        }

        let bookingButtonText = isAvailable ? "Prendre rendez-vous" : "Vérifier ce centre"
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

        var phoneText: String?
        if let phoneNumber = vaccinationCentre.metadata?.phoneNumber {
            do {
                let parsedPhoneNumber = try phoneNumberKit.parse(
                    phoneNumber,
                    withRegion: "FR",
                    ignoreType: true
                )
                phoneText = phoneNumberKit.format(parsedPhoneNumber, toType: .national)
            }
            catch {
                phoneText = phoneNumber
            }
        }

        return VaccinationBookingCellViewModel(
            dayText: dayString,
            timeText: timeString,
            addressNameText: vaccinationCentre.nom ?? "Nom du centre indisponible",
            addressText: vaccinationCentre.metadata?.address ?? "Addresse indisponible",
            phoneText: phoneText,
            bookingButtonText: bookingButtonAttributedText,
            vaccineTypesText: vaccinationCentre.vaccineType?.joined(separator: ", "),
            dosesCount: vaccinationCentre.appointmentCount,
            isAvailable: isAvailable,
            url: url,
            partnerLogo: partnerLogo
        )
    }

    func bookingLink(at indexPath: IndexPath) -> URL? {
        guard
            let vaccinationCentre = allVaccinationCentres[safe: indexPath.row],
            let bookingUrlString = vaccinationCentre.url,
            let bookingUrl = URL(string: bookingUrlString),
            bookingUrl.isValid
        else {
            return nil
        }

        AppAnalytics.didSelectVaccinationCentre(vaccinationCentre)

        return bookingUrl
    }

    private func didFetchVaccinationCentres(_ vaccinationCentres: VaccinationCentres) {
        let isEmpty = vaccinationCentres.centresDisponibles.isEmpty && vaccinationCentres.centresIndisponibles.isEmpty
        allVaccinationCentres = vaccinationCentres.centresDisponibles + vaccinationCentres.centresIndisponibles

        let dosesCount = vaccinationCentres.centresDisponibles.reduce(0) { $0 + ($1.appointmentCount ?? 0) }
        let headerViewModel = VaccinationCentresHeaderViewModel(
            dosesCount: dosesCount,
            countyName: county.nomDepartement ?? "",
            availableCentresCount: vaccinationCentres.centresDisponibles.count,
            allCentresCount: allVaccinationCentres.count
        )

        var footerText: String?
        if let lastUpdate = vaccinationCentres.lastUpdated?.toDate(nil, region: region) {
            let lastUpdateDay = lastUpdate.toString(.date(.short))
            let lastUpdateTime = lastUpdate.toString(.time(.short))
            footerText = "Dernière mise à jour le \(lastUpdateDay) à \(lastUpdateTime)"
        }

        delegate?.reloadTableViewHeader(with: headerViewModel)
        delegate?.reloadTableViewFooter(with: footerText)
        delegate?.reloadTableView(isEmpty: isEmpty)
    }

    private func handleError(_ error: APIResponseStatus) {

    }

    public func fetchVaccinationCentres() {
        guard !isLoading else { return }
        isLoading = true

        guard let countyCode = county.codeDepartement else {
            delegate?.displayError(withMessage: "County code missing")
            return
        }

        apiService.fetchVaccinationCentres(country: countyCode) { [weak self] data, status in
            self?.isLoading = false

            if let vaccinationCentres = data {
                self?.didFetchVaccinationCentres(vaccinationCentres)
            } else {
                self?.handleError(status)
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

