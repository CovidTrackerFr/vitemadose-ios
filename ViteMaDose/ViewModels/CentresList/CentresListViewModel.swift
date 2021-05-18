//
//  CentresListViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import Foundation
import UIKit
import PhoneNumberKit
import PromiseKit
import MapKit

enum CentresListSection: CaseIterable {
    case heading
    case centres
}

enum CentresListCell: Hashable {
    case title(HomeTitleCellViewData)
    case stats(CentresStatsCellViewData)
    case centre(CentreViewData)
    case sort(CentresSortOptionsCellViewData)
    case disclaimer(CentreDataDisclaimerCellViewData)
}

enum CentresListSortOption: Equatable {
    case closest
    case fastest

    init(_ value: Int) {
        switch value {
        case 0:
            self = .closest
        case 1:
            self = .fastest
        default:
            assertionFailure("Value should either be 0 or 1")
            self = .closest
        }
    }

    var index: Int {
        switch self {
        case .closest:
            return 0
        case .fastest:
            return 1
        }
    }
}

protocol CentresListViewModelProvider {
    var searchResult: LocationSearchResult { get }
    func load(animated: Bool)
    func sortList(by order: CentresListSortOption)
    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, location: CLLocation)?
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
    private(set) var searchResult: LocationSearchResult
    private let phoneNumberKit: PhoneNumberKit
    private let userDefaults: UserDefaults

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: vaccinationCentresList.isEmpty)
        }
    }

    private var locationVaccinationCentres: LocationVaccinationCentres = []
    private var vaccinationCentresList: [VaccinationCentre] = []

    private var footerText: String?
    weak var delegate: CentresListViewModelDelegate?

    init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        searchResult: LocationSearchResult,
        phoneNumberKit: PhoneNumberKit = PhoneNumberKit(),
        userDefaults: UserDefaults = .shared
    ) {
        self.apiService = apiService
        self.searchResult = searchResult
        self.phoneNumberKit = phoneNumberKit
        self.userDefaults = userDefaults
    }

    private func reloadTableView(animated: Bool) {
        let availableCentres = getVaccinationCentres(
            for: locationVaccinationCentres.allAvailableCentres,
            sortOption: userDefaults.centresListSortOption
        )
        let unavailableCentres = getVaccinationCentres(
            for: locationVaccinationCentres.allUnavailableCentres,
            sortOption: .closest
        )

        // Merge arrays and make sure there is no centre with duplicate ids
        vaccinationCentresList = (availableCentres + unavailableCentres).unique(by: \.id)

        let headingCells = createHeadingCells(
            appointmentsCount: availableCentres.allAppointmentsCount,
            availableCentresCount: availableCentres.count,
            centresCount: vaccinationCentresList.count
        )
        let centresCells = createVaccinationCentreCellsFor(for: vaccinationCentresList)
        let footerText = locationVaccinationCentres.first?.formattedLastUpdated

        AppAnalytics.trackSearchEvent(
            searchResult: searchResult,
            appointmentsCount: availableCentres.allAppointmentsCount,
            availableCentresCount: availableCentres.count,
            unAvailableCentresCount: unavailableCentres.count,
            sortOption: userDefaults.centresListSortOption
        )

        delegate?.reloadTableView(with: headingCells, andCentresCells: centresCells, animated: animated)
        delegate?.reloadTableViewFooter(with: footerText)
    }

    private func createHeadingCells(appointmentsCount: Int, availableCentresCount: Int, centresCount: Int) -> [CentresListCell] {
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
            availableCentresCount: availableCentresCount,
            allCentresCount: centresCount
        )

        var cells: [CentresListCell] = [
            .title(mainTitleViewData),
            .stats(statsCellViewData)
        ]

        guard centresCount > 0 else {
            return cells
        }

        let centresListTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.centresListTitle,
            bottomMargin: 0
        )
        cells.append(.title(centresListTitleViewData))

        if RemoteConfiguration.shared.dataDisclaimerEnabled {
            /// Pop-up Disclaimer
            let centreDataDisclaimerCellViewData = CentreDataDisclaimerCellViewData(
                contentText: RemoteConfiguration.shared.dataDisclaimerMessage
            )
            cells.append(.disclaimer(centreDataDisclaimerCellViewData))
        }

        if searchResult.coordinates != nil {
            let viewData = CentresSortOptionsCellViewData(sortOption: userDefaults.centresListSortOption)
            cells.append(.sort(viewData))
        }

        return cells
    }

    private func createVaccinationCentreCellsFor(for vaccinationCentres: [VaccinationCentre]) -> [CentresListCell] {
        guard !vaccinationCentres.isEmpty else {
            return []
        }

        let vaccinationCentreCellsViewData = vaccinationCentres.map(getVaccinationCentreCellViewData)
        return vaccinationCentreCellsViewData.map(CentresListCell.centre)
    }

    /// Creates a list of vaccination centre sorted by distance
    /// Centres are also filtered by maximum distance from the selected location
    /// The maximum distance value is set in our remote config file
    /// - Parameter centres: a list of vaccination centres returned by the API
    /// - Returns: array of filtered and sorted centres
    private func getVaccinationCentres(
        for centres: [VaccinationCentre],
        sortOption: CentresListSortOption
    ) -> [VaccinationCentre] {
        let centres = centres.filter(searchResult.filterVaccinationCentreByDistance)

        switch sortOption {
        case .closest:
            return centres.sorted(by: searchResult.sortVaccinationCentresByLocation)
        case .fastest:
            return centres.sorted(by: searchResult.sortVaccinationCentresByAppointment)
        }
    }

    private func getVaccinationCentreCellViewData(_ centre: VaccinationCentre) -> CentreViewData {
        var partnerLogo: UIImage?
        if let platform = centre.plateforme {
            partnerLogo =  PartnerLogo(rawValue: platform)?.image
        }

        let bookingButtonText = centre.isAvailable
            ? Localization.Location.book_button + String.space
            : Localization.Location.verify_button + String.space

        return CentreViewData(
            id: centre.id,
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

        let departmentCodes = [searchResult.departmentCode] + searchResult.nearDepartmentCodes
        let departmentsToLoad: [Promise<VaccinationCentres>] = departmentCodes.map(createDepartmentPromise)

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
                self?.locationVaccinationCentres = vaccinationCentres
                self?.reloadTableView(animated: animated)
            }
        }
    }

    func sortList(by order: CentresListSortOption) {
        userDefaults.centresListSortOption = order
        reloadTableView(animated: false)
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

    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, location: CLLocation)? {
        guard
            let centre = vaccinationCentresList[safe: indexPath.row],
            let name = centre.nom,
            let location = centre.locationAsCLLocation
        else {
            return nil
        }
        return (name, centre.metadata?.address, location)
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
