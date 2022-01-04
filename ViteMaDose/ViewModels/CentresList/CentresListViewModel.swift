// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import UIKit
import PhoneNumberKit
import PromiseKit
import MapKit
import Haptica

public typealias DatedSlot = (date: String, slot: Slot)
public typealias VaccinationCentresWithDatedSlot = [VaccinationCentre: [DatedSlot]]

// MARK: - Centres List ViewModel

class CentresListViewModel {
    private let apiService: BaseAPIServiceProvider
    private let phoneNumberKit: PhoneNumberKit
    private let searchResult: LocationSearchResult?
    private(set) var userDefaults: UserDefaults
    private let notificationCenter: UNUserNotificationCenter
    private let remoteConfig: RemoteConfiguration

    internal var sortOption: CentresListSortOption {
        return userDefaults.centresListSortOption
    }

    internal var shouldFooterText: Bool {
        return true
    }

    internal var shouldAnimateReload: Bool {
        return false
    }

    private var isLoading = false {
        didSet {
            delegate?.updateLoadingState(isLoading: isLoading, isEmpty: vaccinationCentresList.isEmpty)
        }
    }

    private var vaccinationCentresForDepartments: DepartmentVaccinationCentres = []
    private var departmentSlots: [DepartmentSlots] = []
    private var vaccinationCentresWithDatedSlots: VaccinationCentresWithDatedSlot = [:]

    private(set) var vaccinationCentresList: [VaccinationCentre] = []
    private var availableCentres: [VaccinationCentre] = []
    private var unavailableCentres: [VaccinationCentre] = []

    private var footerText: String?
    weak var delegate: CentresListViewModelDelegate?

    init(
        apiService: BaseAPIServiceProvider = BaseAPIService(),
        searchResult: LocationSearchResult?,
        phoneNumberKit: PhoneNumberKit = PhoneNumberKit(),
        userDefaults: UserDefaults = .shared,
        notificationCenter: UNUserNotificationCenter = .current(),
        remoteConfig: RemoteConfiguration = .shared
    ) {
        self.apiService = apiService
        self.searchResult = searchResult
        self.phoneNumberKit = phoneNumberKit
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.remoteConfig = remoteConfig
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
            let viewData = CentresSortOptionsCellViewData(sortOption: sortOption)
            cells.append(.sort(viewData))
        }

        if remoteConfig.dataDisclaimerEnabled, let disclaimerMessage = remoteConfig.dataDisclaimerMessage {
            // Disclaimer cell
            let centreDataDisclaimerCellViewData = CentreDataDisclaimerCellViewData(
                contentText: disclaimerMessage
            )
            cells.append(.disclaimer(centreDataDisclaimerCellViewData))
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
            partnerLogo = PartnerLogo(rawValue: platform)?.image
        }

        let bookingButtonText = centre.isAvailable
            ? Localization.Location.book_button + String.space
            : Localization.Location.verify_button + String.space

        var notificationsType: FollowedCentre.NotificationsType?
        if let internalId = centre.internalId, let department = centre.departement {
            if let followedCentre = userDefaults.followedCentre(forDepartment: department, id: internalId) {
                notificationsType = followedCentre.notificationsType
            } else {
                notificationsType = FollowedCentre.NotificationsType.none
            }
        }

        let appointmentsCount: Int? = {
            guard let datedSlots = vaccinationCentresWithDatedSlots[centre] else {
                return nil
            }

            let count = datedSlots.reduce(0) { partialResult, datedSlot in
                switch sortOption {
                case .closest, .fastest:
                    return partialResult + datedSlot.slot.dosesCount(for: .all)
                case .thirdDose:
                    return partialResult + datedSlot.slot.dosesCount(for: .thirdDose)
                }
            }

            return count
        }()

        return CentreViewData(
            id: centre.id,
            dayText: centre.nextAppointmentDay,
            timeText: centre.nextAppointmentTime,
            addressNameText: centre.formattedCentreName(selectedLocation: searchResult?.coordinates?.asCCLocation),
            addressText: centre.metadata?.address ?? Localization.Location.unavailable_address,
            phoneText: centre.formattedPhoneNumber(phoneNumberKit),
            bookingButtonText: bookingButtonText,
            vaccineTypesText: centre.vaccinesTypeText,
            centerTypeText: centre.type?.localized,
            appointmentsCount: appointmentsCount,
            isAvailable: centre.isAvailable,
            partnerLogo: partnerLogo,
            partnerName: centre.plateforme,
            notificationsType: notificationsType
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

    private func createDepartmentSlotsPromises(_ codes: [String]) -> [Promise<DepartmentSlots>] {
        return codes.map { code in
            return Promise { seal in
                apiService.fetchDepartmentSlots(departmentCode: code) { result in
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

    private func handleReload(animated: Bool) {
        createVaccinationCentresList()
        self.reloadTableView(animated: animated)
    }

    // MARK: - Overridable

    internal func reloadTableView(animated: Bool) {
        let headingCells = createHeadingCells(
            appointmentsCount: departmentSlots.allSlotsCount,
            availableCentresCount: availableCentres.allAvailableCentresCount,
            centresCount: availableCentres.count + unavailableCentres.count
        )

        let centresCells = createVaccinationCentreCellsFor(for: vaccinationCentresList)
        let footerText = vaccinationCentresForDepartments.first?.formattedLastUpdated

        trackSearchResult(availableCentres: availableCentres, unavailableCentres: unavailableCentres)
        DispatchQueue.main.async {
            self.delegate?.reloadTableView(with: headingCells, andCentresCells: centresCells, animated: animated)
            self.delegate?.reloadTableViewFooter(with: self.shouldFooterText ? footerText : nil)
        }
    }

    /// Creates a list of vaccination centre sorted by distance
    /// Centres are also filtered by maximum distance from the selected location
    /// The maximum distance value is set in our remote config file
    /// - Parameter centres: a list of vaccination centres returned by the API
    /// - Returns: array of filtered and sorted centres
    internal func getVaccinationCentres(for centres: [VaccinationCentre]) -> [VaccinationCentre] {
        // If search result has no coordinates (department), sort options are not displayed and
        // centres are ordered by appointment time
        guard searchResult?.coordinates != nil else {
            return centres.sorted(by: VaccinationCentre.sortedByAppointment)
        }

        switch sortOption {
        case .closest:
            if let searchResult = searchResult {
                return centres.sorted(by: searchResult.sortVaccinationCentresByLocation)
            } else {
                // Fall back if search result is missing
                assertionFailure("Tried to sort by distance with invalid search result")
                return centres.sorted(by: VaccinationCentre.sortedByAppointment)
            }
        case .fastest:
            return centres
                .sorted(by: VaccinationCentre.sortedByAppointment)
        case .thirdDose:
            return centres
                .filter { centre in
                    guard let datedSlotsForCentre = vaccinationCentresWithDatedSlots[centre] else {
                        return false
                    }
                    return datedSlotsForCentre.contains(where: { $0.slot.hasThirdDoses })
                }
                .sorted(by: VaccinationCentre.sortedByAppointment)
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
            appointmentsCount: departmentSlots.allSlotsCount,
            availableCentresCount: availableCentres.count,
            unAvailableCentresCount: unavailableCentres.count,
            sortOption: sortOption
        )
    }

    internal var departmentsToLoad: [String] {
        let departmentCodes: [String?] = [searchResult?.selectedDepartmentCode] + (searchResult?.departmentCodes ?? [])
        return departmentCodes.compacted
    }
}

// MARK: - Centres List View Model Provider

extension CentresListViewModel: CentresListViewModelProvider {

    func load(animated: Bool) {
        guard !isLoading else { return }
        isLoading = true

        let departmentsToLoad = departmentsToLoad
        let departmentsToLoadPromises: [Promise<VaccinationCentres>] = createDepartmentsPromises(departmentsToLoad)
        let departmentsSlotsToLoadPromises: [Promise<DepartmentSlots>] = createDepartmentSlotsPromises(departmentsToLoad)

        when(fulfilled: departmentsToLoadPromises).then { foundVaccinationCentres in
            when(fulfilled: departmentsSlotsToLoadPromises).map({ ($0, foundVaccinationCentres) })
        }.done { [weak self] departmentSlots, foundVaccinationCentres in
            guard let self = self else { return }

            self.isLoading = false
            self.vaccinationCentresForDepartments = foundVaccinationCentres
            self.departmentSlots = departmentSlots
            self.handleReload(animated: animated)
        }.catch { [weak self] error in
            self?.isLoading = false
            self?.handleError(error)
        }
    }

    private func createVaccinationCentresList() {
        availableCentres = vaccinationCentresForDepartments.allAvailableCentres
        unavailableCentres = vaccinationCentresForDepartments.allUnavailableCentres

        // If search result, filter by maximum distance
        if let searchResult = self.searchResult {
            availableCentres = availableCentres.filter(searchResult.filterVaccinationCentreByDistance)
            unavailableCentres = unavailableCentres.filter(searchResult.filterVaccinationCentreByDistance)
        }

        // Merge arrays and make sure there is no centre with duplicate ids
        let allCentres = (availableCentres + unavailableCentres).unique(by: \.id)

        for vaccinationCentre in allCentres {
            let departmentCode = vaccinationCentre.departement
            guard
                let dailySlotsInVaccinationCentre = departmentSlots.first(where: { $0.departmentNumber == departmentCode }),
                let dailySlots = dailySlotsInVaccinationCentre.dailySlots
            else {
                return
            }

            let slots: [DatedSlot] = dailySlots.compactMap { slot in
                guard let slotForDepartment = slot.slotsPerLocation?.first(where: { $0.locationID == vaccinationCentre.internalId }) else {
                    return nil
                }
                return (date: slot.date.emptyIfNil, slot: slotForDepartment)
            }

            self.vaccinationCentresWithDatedSlots[vaccinationCentre] = slots
        }

        vaccinationCentresList = getVaccinationCentres(for: allCentres)
    }

    func sortList(by order: CentresListSortOption) {
        userDefaults.centresListSortOption = order
        createVaccinationCentresList()
        reloadTableView(animated: false)
    }

    func followCentre(at indexPath: IndexPath, notificationsType: FollowedCentre.NotificationsType) {
        guard let centre = vaccinationCentresList[safe: indexPath.row],
              let departmentCode = centre.departement,
              let internalId = centre.internalId
        else {
            return
        }
        let followedCentre = FollowedCentre(
            id: internalId,
            notificationsType: notificationsType
        )

        if case .none = followedCentre.notificationsType {
            userDefaults.addFollowedCentre(followedCentre, forDepartment: departmentCode)
            reloadTableView(animated: shouldAnimateReload)
            return
        }

        FCMHelper.shared.subscribeToCentreTopic(
            withDepartmentCode: departmentCode,
            andCentreId: internalId
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.userDefaults.addFollowedCentre(followedCentre, forDepartment: departmentCode)
                self.reloadTableView(animated: self.shouldAnimateReload)
                Haptic.notification(.success).generate()
            case let .failure(error):
                self.delegate?.presentLoadError(error)
            }
        }
    }

    func unfollowCentre(at indexPath: IndexPath) {
        guard let centre = vaccinationCentresList[safe: indexPath.row],
              let departmentCode = centre.departement,
              let internalId = centre.internalId
        else {
            return
        }

        guard let followedCentre = userDefaults.followedCentre(forDepartment: departmentCode, id: internalId) else {
            assertionFailure("Followed centre not found for department \(departmentCode) and centre id \(internalId)")
            return
        }

        if case .none = followedCentre.notificationsType {
            userDefaults.removedFollowedCentre(internalId, forDepartment: departmentCode)
            reloadTableView(animated: shouldAnimateReload)
            return
        }

        FCMHelper.shared.unsubscribeToCentreTopic(
            withDepartmentCode: departmentCode,
            andCentreId: internalId
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.userDefaults.removedFollowedCentre(internalId, forDepartment: departmentCode)
                self.reloadTableView(animated: self.shouldAnimateReload)
                Haptic.impact(.medium).generate()
            case let .failure(error):
                self.delegate?.presentLoadError(error)
            }
        }
    }

    func isCentreFollowed(at indexPath: IndexPath) -> Bool? {
        guard let centre = vaccinationCentresList[safe: indexPath.row],
              let departmentCode = centre.departement
        else {
            return nil
        }
        return userDefaults.isCentreFollowed(centre.id, forDepartment: departmentCode)
    }

    func requestNotificationsAuthorizationIfNeeded(completion: @escaping () -> Void) {
        FCMHelper.shared.requestNotificationsAuthorizationIfNeeded(
            notificationCenter,
            completion: completion
        )
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
