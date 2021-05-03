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
    private enum Constant {
        static let maximumDistanceInKm = 75.0
    }

    private let apiService: BaseAPIServiceProvider
    private let phoneNumberKit = PhoneNumberKit()

    private var vaccinationCentresList: [VaccinationCentre] = []
    private var locationVaccinationCentres: LocationVaccinationCentres = []

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: vaccinationCentresList.isEmpty)
        }
    }

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

    private func handleReload(with vaccinationCentres: LocationVaccinationCentres) {
        handleLoad(with: vaccinationCentres, animated: true)
    }

    private func updateCells() {
        let availableCentres = getVaccinationCentres(for: locationVaccinationCentres.flatMap(\.centresDisponibles))
        let unavailableCentres = getVaccinationCentres(for: locationVaccinationCentres.flatMap(\.centresIndisponibles))

        vaccinationCentresList = availableCentres + unavailableCentres

        let appointmentsCount = availableCentres.reduce(0) { $0 + ($1.appointmentCount ?? 0) }
        let vaccinationCentreCellsViewData = vaccinationCentresList.map(getVaccinationCentreViewData)

        let mainTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.mainTitleAttributedText(
                withAppointmentsCount: appointmentsCount,
                andSearchResult: searchResult
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

        guard !vaccinationCentresList.isEmpty else {
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
        guard let lastUpdate = locationVaccinationCentres
                .first?
                .lastUpdated?
                .toDate(nil, region: AppConstant.franceRegion)
        else {
            footerText = nil
            return
        }

        let lastUpdateDay = lastUpdate.toString(.date(.short))
        let lastUpdateTime = lastUpdate.toString(.time(.short))
        footerText = Localization.Location.last_update.format(lastUpdateDay, lastUpdateTime)
    }

    private func getVaccinationCentres(for centres: [VaccinationCentre]) -> [VaccinationCentre] {
        return centres
            .filter(searchResult.filterVaccinationCentreByDistance(vaccinationCentre:))
            .sorted(by: searchResult.sortVaccinationCentresByLocation(_:_:))
    }

    private func getVaccinationCentreViewData(_ centre: VaccinationCentre) -> CentreViewData {
        var partnerLogo: UIImage?
        if let platform = centre.plateforme {
            partnerLogo =  PartnerLogo(rawValue: platform)?.image
        }

        let bookingButtonText = centre.isAvailable
            ? Localization.Location.book_button + String.space
            : Localization.Location.verify_button + String.space

        return CentreViewData(
            dayText: centre.nextAppointmentDay,
            timeText: centre.nextAppointmentTime,
            addressNameText: centre.formattedCentreName(selectedLocation: searchResult.coordinates?.asCCLocation),
            addressText: centre.metadata?.address ?? Localization.Location.unavailable_address,
            phoneText: centre.formattedPhoneNumber(phoneNumberKit),
            bookingButtonText: bookingButtonText,
            vaccineTypesText: centre.vaccineType?.joined(separator: String.commaWithSpace),
            appointmentsCount: centre.appointmentCount,
            isAvailable: centre.isAvailable,
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
            var errors: [Error] = []

            let vaccinationCentres = results.compactMap { result -> VaccinationCentres? in
                switch result {
                case let .fulfilled(centres):
                    return centres
                case let .rejected(error):
                    errors.append(error)
                    return nil
                }
            }

            if let error = errors.first {
                self?.handleError(error)
            } else {
                self?.handleLoad(with: vaccinationCentres, animated: animated)
            }
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
        return vaccinationCentresList[safe: indexPath.row]?.phoneUrl
    }

    func bookingLink(at indexPath: IndexPath) -> URL? {
        guard let vaccinationCentre = vaccinationCentresList[safe: indexPath.row] else {
            return nil
        }
        AppAnalytics.didSelectVaccinationCentre(vaccinationCentre)
        return vaccinationCentre.appointmentUrl
    }
}
