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
import Moya
import PromiseKit

enum CentresListSection: CaseIterable {
    case heading
    case centres
}

enum CentresListCell: Hashable {
    case title(HomeTitleCellViewData)
    case stats(CentresStatsCellViewData)
    case centre(CentreViewData)
}

protocol CentresListViewModelProvider {
    var searchResult: LocationSearchResult { get }
    func load(animated: Bool)
    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, lat: Double, long: Double)?
    func phoneNumberLink(at indexPath: IndexPath) -> URL?
    func bookingLink(at indexPath: IndexPath) -> URL?
}

protocol CentresListViewModelDelegate: AnyObject {
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
    private let apiService: BaseAPIServiceProvider
    private let phoneNumberKit = PhoneNumberKit()

    private var vaccinationCentresList: [VaccinationCentre] = []
    private var locationVaccinationCentres: LocationVaccinationCentres = []

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: vaccinationCentresList.isEmpty)
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

    var searchResult: LocationSearchResult
    weak var delegate: CentresListViewModelDelegate?

    init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        searchResult: LocationSearchResult
    ) {
        self.apiService = apiService
        self.searchResult = searchResult
    }

    private func handleLoad(with locationVaccinationCentres: LocationVaccinationCentres, animated: Bool) {
        self.locationVaccinationCentres = locationVaccinationCentres

        updateCells()
        updateFooterText()

        delegate?.reloadTableView(with: headingCells, andCentresCells: centresCells, animated: animated)
        delegate?.reloadTableViewFooter(with: footerText)
    }

    private func handleReload(with vaccinationCentres: [VaccinationCentres]) {
        handleLoad(with: vaccinationCentres, animated: true)
    }

    private func updateCells() {
        let availableCentres = locationVaccinationCentres.flatMap(\.centresDisponibles)
        let unavailableCentres =  locationVaccinationCentres.flatMap(\.centresIndisponibles)

        let isEmpty = availableCentres.isEmpty && unavailableCentres.isEmpty
        vaccinationCentresList = availableCentres + unavailableCentres

        let appointmentsCount = availableCentres.reduce(0) { $0 + ($1.appointmentCount ?? 0) }
        let vaccinationCentreCellsViewData = vaccinationCentresList.map({ getVaccinationCentreViewData($0) })

        let mainTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.mainTitleAttributedText(
                withAppointmentsCount: appointmentsCount,
                andDepartmentName: searchResult.name
            ),
            topMargin: 25,
            bottomMargin: 0
        )

        let statsCellViewData = CentresStatsCellViewData(
            appointmentsCount: appointmentsCount,
            availableCentresCount: availableCentres.count,
            allCentresCount: vaccinationCentresList.count
        )

        headingCells = [
            .title(mainTitleViewData),
            .stats(statsCellViewData)
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
            CentresListCell.centre($0)
        })

        headingCells.append(.title(centresListTitleViewData))
        centresCells = vaccinationCentresViewData
    }

    private func updateFooterText() {
        guard let lastUpdate = locationVaccinationCentres.first?.lastUpdated?.toDate(nil, region: region) else {
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

        let nextAppointment = centre.prochainRdv
        let dayString = nextAppointment?.toString(with: .date(.long), region: region)
        let timeString = nextAppointment?.toString(with: .time(.short), region: region)

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

    private func handleError(_ error: Error) {
        delegate?.presentLoadError(error)
    }
}

// MARK: - Centres List ViewModelProvider

extension CentresListViewModel: CentresListViewModelProvider {

    func load(animated: Bool) {
        guard !isLoading else { return }
        isLoading = true

        let departmentCodes = [searchResult.departmentCode] + searchResult.departmentCodes
        let departmentsToLoad: [Promise<VaccinationCentres>] = departmentCodes.map(createDepartmentPromise(code:))

        when(resolved: departmentsToLoad).done { [weak self] results in
            self?.isLoading = false
            let vaccinationCentres = results
                .compactMap { result -> VaccinationCentres? in
                    switch result {
                    case let .fulfilled(centres):
                        return centres
                    case .rejected:
                        return nil
                    }
                }
            self?.handleLoad(with: vaccinationCentres, animated: animated)
        }
    }

    private func createDepartmentPromise(code: String) -> Promise<VaccinationCentres> {
        return Promise { seal in
            apiService.fetchVaccinationCentres(departmentCode: code) { result in
                switch result {
                case let .success(centres):
                    seal.fulfill(centres)
                case let .failure(error):
                    seal.reject(error)
                }
            }
        }
    }

    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, lat: Double, long: Double)? {
        guard
            let centre = vaccinationCentresList[safe: indexPath.row],
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
            let vaccinationCentre = vaccinationCentresList[safe: indexPath.row],
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
            let vaccinationCentre = vaccinationCentresList[safe: indexPath.row],
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
