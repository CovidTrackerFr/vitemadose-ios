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

// MARK: - Vaccination Centres Cell ViewModel

enum VaccinationCentresSection: CaseIterable {
    case heading
    case centres
}

enum VaccinationCentresCell: Hashable {
    case title(HomeTitleCellViewData)
    case stats(CentresStatsCellViewData)
    case centre(CentreViewData)
}

protocol VaccinationCentresViewModelProvider {
    var county: County { get }
    var vaccinationCentres: VaccinationCentres? { get }
    func load(animated: Bool)
    func bookingLink(at indexPath: IndexPath) -> URL?
    func phoneNumberLink(at indexPath: IndexPath) -> URL?
}

protocol VaccinationCentresViewModelDelegate: class {
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)

    func presentLoadError(_ error: Error)
    func reloadTableView(
        with headingCells: [VaccinationCentresCell],
        andCentresCells centresCells: [VaccinationCentresCell],
        animated: Bool
    )
    func reloadTableViewFooter(with text: String?)
}

class VaccinationCentresViewModel {
    private let apiService: APIServiceProvider
    private let phoneNumberKit = PhoneNumberKit()

    private var allVaccinationCentres: [VaccinationCentre] = []
    private var isLoading = false {
        didSet {
            let isEmpty = vaccinationCentres == nil
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: isEmpty)
        }
    }

    private lazy var region = Region(
        calendar: Calendar.current,
        zone: Zones.current,
        locale: Locale(identifier: "fr_FR")
    )

    private var headingCells: [VaccinationCentresCell] = []
    private var centresCells: [VaccinationCentresCell] = []
    private var footerText: String?

    var county: County
    var vaccinationCentres: VaccinationCentres?

    weak var delegate: VaccinationCentresViewModelDelegate?

    var numberOfRows: Int {
        return allVaccinationCentres.count
    }

    init(
        apiService: APIServiceProvider = APIService(),
        county: County
    ) {
        self.apiService = apiService
        self.county = county
    }

    private func handleLoad(with vaccinationCentres: VaccinationCentres, animated: Bool) {
        self.vaccinationCentres = vaccinationCentres

        updateCells()
        updateFooterText()

        delegate?.reloadTableView(with: headingCells, andCentresCells: centresCells, animated: animated)
        delegate?.reloadTableViewFooter(with: footerText)
    }

    private func handleReload(with vaccinationCentres: VaccinationCentres) {
        handleLoad(with: vaccinationCentres, animated: true)
    }

    private func updateCells() {
        let availableCentres = vaccinationCentres?.centresDisponibles ?? []
        let unavailableCentres = vaccinationCentres?.centresIndisponibles ?? []
        let isEmpty = availableCentres.isEmpty && unavailableCentres.isEmpty
        allVaccinationCentres = availableCentres + unavailableCentres

        let dosesCount = availableCentres.reduce(0) { $0 + ($1.appointmentCount ?? 0) }
        let vaccinationCentreCellsViewData = allVaccinationCentres.map({ getVaccinationCentreViewData($0) })

        let mainTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.mainTitleAttributedText(
                withDoses: dosesCount,
                andCountyName: county.nomDepartement ?? ""
            ),
            topMargin: 25,
            bottomMargin: 0
        )

        let statsCellViewData = CentresStatsCellViewData(
            dosesCount: dosesCount,
            availableCentresCount: availableCentres.count,
            allCentresCount: allVaccinationCentres.count
        )

        headingCells = [
            .title(mainTitleViewData),
            .stats(statsCellViewData),
        ]

        guard !isEmpty else {
            centresCells.removeAll()
            return
        }

        let centresListTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.centresListTitle,
            bottomMargin: 5
        )
        let vaccinationCentresViewData = vaccinationCentreCellsViewData.map({
            VaccinationCentresCell.centre($0)
        })

        headingCells.append(.title(centresListTitleViewData))
        centresCells = vaccinationCentresViewData
    }

    private func updateFooterText() {
        guard let lastUpdate = vaccinationCentres?.lastUpdated?.toDate(nil, region: region) else {
            footerText = nil
            return
        }

        let lastUpdateDay = lastUpdate.toString(.date(.short))
        let lastUpdateTime = lastUpdate.toString(.time(.short))
        footerText = "Dernière mise à jour le \(lastUpdateDay) à \(lastUpdateTime)"
    }


    func getVaccinationCentreViewData(_ centre: VaccinationCentre) -> CentreViewData {
        var url: URL?
        if let urlString = centre.url {
            url = URL(string: urlString)
        }

        let isAvailable = centre.prochainRdv != nil

        var dayString: String?
        var timeString: String?

        if
            let dateString = centre.prochainRdv,
            let date = dateString.toDate(nil, region: region)
        {
            dayString = date.toString(.date(.long))
            timeString = date.toString(.time(.short))
        }

        var partnerLogo: UIImage?
        if let platform = centre.plateforme {
            partnerLogo =  PartnerLogo(rawValue: platform)?.image
        }

        let bookingButtonText = isAvailable ? "Prendre rendez-vous" : "Vérifier ce centre"

        var phoneText: String?
        if let phoneNumber = centre.metadata?.phoneNumber {
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

        return CentreViewData(
            dayText: dayString,
            timeText: timeString,
            addressNameText: centre.nom ?? "Nom du centre indisponible",
            addressText: centre.metadata?.address ?? "Addresse indisponible",
            phoneText: phoneText,
            bookingButtonText: bookingButtonText,
            vaccineTypesText: centre.vaccineType?.joined(separator: ", "),
            dosesCount: centre.appointmentCount,
            isAvailable: isAvailable,
            url: url,
            partnerLogo: partnerLogo
        )
    }

    private func handleError(_ error: APIResponseStatus) {
        delegate?.presentLoadError(error)
    }
}

// MARK: - VaccinationCentresViewModelProvider

extension VaccinationCentresViewModel: VaccinationCentresViewModelProvider {

    func load(animated: Bool) {
        guard !isLoading else { return }
        isLoading = true

        guard let countyCode = county.codeDepartement else {
            isLoading = false
            handleError(APIResponseStatus.preconditionRequired)
            return
        }

        apiService.fetchVaccinationCentres(country: countyCode) { [weak self] data, status in
            self?.isLoading = false

            if let vaccinationCentres = data {
                self?.handleLoad(with: vaccinationCentres, animated: animated)
            } else {
                self?.handleError(status)
            }
        }
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

    func phoneNumberLink(at indexPath: IndexPath) -> URL? {
        guard
            let vaccinationCentre = allVaccinationCentres[safe: indexPath.row],
            let phoneNumber = vaccinationCentre.metadata?.phoneNumber,
            let phoneNumberUrl = URL(string: "tel://\(phoneNumber)"),
            phoneNumberUrl.isValid
        else {
            return nil
        }

        return phoneNumberUrl
    }
}
