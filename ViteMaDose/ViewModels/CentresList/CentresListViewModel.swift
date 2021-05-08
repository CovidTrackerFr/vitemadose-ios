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

protocol CentresListViewModelProvider: AnyObject {
    var delegate: CentresListViewModelDelegate? { get set }
    func load(animated: Bool)
    func sortList(by order: CentresListSortOption)
    func centreLocation(at indexPath: IndexPath) -> (name: String, address: String?, location: CLLocation)?
    func phoneNumberLink(at indexPath: IndexPath) -> URL?
    func bookingLink(at indexPath: IndexPath) -> URL?
    func followCentre(at indexPath: IndexPath, watch: Bool)
    func unfollowCentre(at indexPath: IndexPath)
    func isCentreFollowed(at indexPath: IndexPath) -> Bool?
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
    private let phoneNumberKit: PhoneNumberKit
    private let searchResult: LocationSearchResult?
    private(set) var userDefaults: UserDefaults

    internal var sortOption: CentresListSortOption {
        return userDefaults.centresListSortOption
    }

    internal var shouldFooterText: Bool {
        return true
    }

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: vaccinationCentresList.isEmpty)
        }
    }

    private var locationVaccinationCentres: LocationVaccinationCentres = []
    private(set) var vaccinationCentresList: [VaccinationCentre] = []

    private var footerText: String?
    weak var delegate: CentresListViewModelDelegate?

    init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        searchResult: LocationSearchResult?,
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

        trackSearchResult(availableCentres: availableCentres, unavailableCentres: unavailableCentres)
        delegate?.reloadTableView(with: headingCells, andCentresCells: centresCells, animated: animated)
        delegate?.reloadTableViewFooter(with: shouldFooterText ? footerText : nil)
    }

    internal func createHeadingCells(appointmentsCount: Int, availableCentresCount: Int, centresCount: Int) -> [CentresListCell] {
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

        if searchResult?.coordinates != nil {
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
            addressNameText: centre.formattedCentreName(selectedLocation: searchResult?.coordinates?.asCCLocation),
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

    private func createDepartmentsPromises(_ codes: [String]) -> [Promise<VaccinationCentres>] {
        return codes.map { code in
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
    }

    // MARK: - Ovveridables

    /// Creates a list of vaccination centre sorted by distance
    /// Centres are also filtered by maximum distance from the selected location
    /// The maximum distance value is set in our remote config file
    /// - Parameter centres: a list of vaccination centres returned by the API
    /// - Returns: array of filtered and sorted centres
    internal func getVaccinationCentres(
        for centres: [VaccinationCentre],
        sortOption: CentresListSortOption
    ) -> [VaccinationCentre] {
        guard let searchResult = self.searchResult else {
            assertionFailure("Search result should not be nil")
            return centres
        }
        let centres = centres.filter(searchResult.filterVaccinationCentreByDistance)

        switch sortOption {
        case .closest:
            return centres.sorted(by: searchResult.sortVaccinationCentresByLocation)
        case .fastest:
            return centres.sorted(by: VaccinationCentre.sortedByAppointment)
        }
    }

    internal func trackSearchResult(
        availableCentres: [VaccinationCentre],
        unavailableCentres: [VaccinationCentre]
    ) {
        guard let searchResult = self.searchResult else {
            assertionFailure("Search result should not be nil")
            return
        }

        AppAnalytics.trackSearchEvent(
            searchResult: searchResult,
            appointmentsCount: availableCentres.allAppointmentsCount,
            availableCentresCount: availableCentres.count,
            unAvailableCentresCount: unavailableCentres.count,
            sortOption: userDefaults.centresListSortOption
        )
    }

    internal func departmentsToLoad() -> [String] {
        let departmentCodes: [String?] = [searchResult?.selectedDepartmentCode] + (searchResult?.departmentCodes ?? [])
        return departmentCodes.compactMap({ $0 })
    }
}

// MARK: - Centres List ViewModelProvider

extension CentresListViewModel: CentresListViewModelProvider {

    func load(animated: Bool) {
        guard !isLoading else { return }
        isLoading = true

        let departmentsToLoadPromises: [Promise<VaccinationCentres>] = createDepartmentsPromises(departmentsToLoad())

        when(resolved: departmentsToLoadPromises).done { [weak self] results in
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

    func followCentre(at indexPath: IndexPath, watch: Bool) {
        guard let centre = vaccinationCentresList[safe: indexPath.row],
              let departmentCode = centre.departement,
              let internalId = centre.internalId
        else {
            return
        }
        let followedCentre = FollowedCentre(id: internalId, isWatching: watch)
        userDefaults.addFollowedCentre(followedCentre, forDepartment: departmentCode)
        reloadTableView(animated: true)
    }

    func unfollowCentre(at indexPath: IndexPath) {
        guard let centre = vaccinationCentresList[safe: indexPath.row],
              let departmentCode = centre.departement,
              let internalId = centre.internalId
        else {
            return
        }
        userDefaults.removedFollowedCentre(internalId, forDepartment: departmentCode)
        reloadTableView(animated: true)
    }

    func isCentreFollowed(at indexPath: IndexPath) -> Bool? {
        guard let centre = vaccinationCentresList[safe: indexPath.row],
              let departmentCode = centre.departement
        else {
            return nil
        }
        return userDefaults.isCentreFollowed(centre.id, forDepartment: departmentCode)
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
