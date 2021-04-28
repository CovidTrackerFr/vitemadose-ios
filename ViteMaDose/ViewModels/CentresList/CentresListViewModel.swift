//
//  CentresListViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import Foundation
import SwiftDate
import UIKit
import PhoneNumberKit
import APIRequest

enum CentresListSection: CaseIterable {
    case heading
    case centres
}

enum CentresListCell: Hashable {
    case title(HomeTitleCellViewData)
    case sorting(CentresSortingCellViewData)
    case stats(CentresStatsCellViewData)
    case centre(CentreViewData)
}

enum CentresSortOrder: Int {
    case auPlusProche = 0
    case auPlusVite = 1
}

protocol CentresListViewModelProvider {
    var county: County { get }
    var vaccinationCentres: VaccinationCentres? { get }
    func load(animated: Bool)
    func sort(animated: Bool)
    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, lat: Double, long: Double)?
    func phoneNumberLink(at indexPath: IndexPath) -> URL?
    func bookingLink(at indexPath: IndexPath) -> URL?
}

protocol CentresListViewModelDelegate: class {
    func updateLoadingState(isLoading: Bool, isEmpty: Bool)

    func presentLoadError(_ error: Error)
    func reloadTableView(
        with headingCells: [CentresListCell],
        andCentresCells centresCells: [CentresListCell],
        animated: Bool
    )
    func reloadTableViewFooter(with text: String?)
}

// MARK: - Centres List ViewModel

class CentresListViewModel {
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

    private var headingCells: [CentresListCell] = []
    private var centresCells: [CentresListCell] = []
    private var footerText: String?

    var county: County
    var vaccinationCentres: VaccinationCentres?

    var sort: CentresSortOrder = .auPlusProche

    weak var delegate: CentresListViewModelDelegate?

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

        let sortedAvailableCentres = availableCentres.sorted(by: { centre1, centre2 in
            switch sort {
            case .auPlusProche:
                return auPlusProche(centre1, centre2)
            case .auPlusVite:
                return auPlusVite(centre1, centre2)
            }
        })

        allVaccinationCentres = sortedAvailableCentres + unavailableCentres

        let appointmentsCount = availableCentres.reduce(0) { $0 + ($1.appointmentCount ?? 0) }
        let vaccinationCentreCellsViewData = allVaccinationCentres.map({ getVaccinationCentreViewData($0) })

        let mainTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.mainTitleAttributedText(
                withAppointmentsCount: appointmentsCount,
                andCountyName: county.nomDepartement ?? ""
            ),
            topMargin: 25,
            bottomMargin: 0
        )

        let statsCellViewData = CentresStatsCellViewData(
            appointmentsCount: appointmentsCount,
            availableCentresCount: availableCentres.count,
            allCentresCount: allVaccinationCentres.count
        )

        headingCells = [
            .title(mainTitleViewData),
            .stats(statsCellViewData)
        ]

        guard !isEmpty else {
            centresCells.removeAll()
            return
        }

        let centresListTitleViewData = CentresSortingCellViewData(
            titleText: CentresTitleCell.centresListTitle,
            bottomMargin: 5,
            mode: sort,
            showSelector: false // TODO: Set to true when search is done by city, otherwise false
        )
        let vaccinationCentresViewData = vaccinationCentreCellsViewData.map({
            CentresListCell.centre($0)
        })

        headingCells.append(.sorting(centresListTitleViewData))
        centresCells = vaccinationCentresViewData
    }

    private func updateFooterText() {
        guard let lastUpdate = vaccinationCentres?.lastUpdated?.toDate(nil, region: region) else {
            footerText = nil
            return
        }

        let lastUpdateDay = lastUpdate.toString(.date(.short))
        let lastUpdateTime = lastUpdate.toString(.time(.short))
        footerText = Localization.Location.last_update.format(lastUpdateDay, lastUpdateTime)
    }

    func getVaccinationCentreViewData(_ centre: VaccinationCentre) -> CentreViewData {
        var url: URL?
        if let urlString = centre.url {
            url = URL(string: urlString)
        }

        let isAvailable = centre.prochainRdv != nil

        let nextAppointment = centre.prochainRdv?.toDate(region: region)
        let dayString = nextAppointment?.toString(.date(.long))
        let timeString = nextAppointment?.toString(.time(.short))

        var partnerLogo: UIImage?
        if let platform = centre.plateforme {
            partnerLogo =  PartnerLogo(rawValue: platform)?.image
        }

        let bookingButtonText = isAvailable
            ? Localization.Location.book_button + String.space
            : Localization.Location.verify_button + String.space

        var phoneText: String?
        if let phoneNumber = centre.metadata?.phoneNumber {
            do {
                let parsedPhoneNumber = try phoneNumberKit.parse(
                    phoneNumber,
                    withRegion: "FR",
                    ignoreType: true
                )
                phoneText = phoneNumberKit.format(parsedPhoneNumber, toType: .national)
            } catch {
                phoneText = phoneNumber
            }
        }

        return CentreViewData(
            dayText: dayString,
            timeText: timeString,
            addressNameText: centre.nom ?? Localization.Location.unavailable_name,
            addressText: centre.metadata?.address ?? Localization.Location.unavailable_address,
            phoneText: phoneText,
            bookingButtonText: bookingButtonText,
            vaccineTypesText: centre.vaccineType?.joined(separator: String.commaWithSpace),
            appointmentsCount: centre.appointmentCount,
            isAvailable: isAvailable,
            url: url,
            partnerLogo: partnerLogo
        )
    }

    private func handleError(_ error: APIResponseStatus) {
        delegate?.presentLoadError(error)
    }
}

// MARK: - Centres List ViewModelProvider

extension CentresListViewModel: CentresListViewModelProvider {

    func load(animated: Bool) {
        guard !isLoading else { return }
        isLoading = true

        guard let countyCode = county.codeDepartement else {
            isLoading = false
            handleError(APIResponseStatus.preconditionRequired)
            return
        }

        apiService.fetchVaccinationCentres(country: countyCode) { [weak self] result in
            self?.isLoading = false

            switch result {
            case let .success(vaccinationCentres):
                self?.handleLoad(with: vaccinationCentres, animated: animated)
            case let .failure(status):
                self?.handleError(status)
            }
        }
    }

    func sort(animated: Bool) {
        updateCells()

        delegate?.reloadTableView(with: headingCells, andCentresCells: centresCells, animated: animated)
    }

    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, lat: Double, long: Double)? {
        guard
            let centre = allVaccinationCentres[safe: indexPath.row],
            let name = centre.nom,
            let lat = centre.location?.latitude,
            let long = centre.location?.longitude
        else {
            return nil
        }
        return (name, centre.metadata?.address, lat, long)
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
}

// MARK: - Sort centre

extension CentresListViewModel {

    func auPlusProche(_ centre1: VaccinationCentre, _ centre2: VaccinationCentre) -> Bool {
        // TODO: Calculate by distance
        guard let rdv1 = centre1.prochainRdv?.toDate(region: region),
              let rdv2 = centre2.prochainRdv?.toDate(region: region) else {
            return false
        }
        return rdv1.isBeforeDate(rdv2, granularity: .second)
    }

    func auPlusVite(_ centre1: VaccinationCentre, _ centre2: VaccinationCentre) -> Bool {
        guard let rdv1 = centre1.prochainRdv?.toDate(region: region),
              let rdv2 = centre2.prochainRdv?.toDate(region: region) else {
            return false
        }
        return rdv1.isBeforeDate(rdv2, granularity: .second)
    }

}
