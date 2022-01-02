// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

final class FollowedCentresViewModel: CentresListViewModel {

    override var shouldAnimateReload: Bool {
        return false
    }

    override var shouldFooterText: Bool {
        return false
    }

    override var sortOption: CentresListSortOption {
        return .fastest
    }

    private var followedCentresIds: [String] {
        return super.userDefaults.followedCentres.flatMap({ $0.value.map(\.id) })
    }

    init() {
        super.init(searchResult: nil)
    }

    override func reloadTableView(animated: Bool) {
        super.reloadTableView(animated: animated)

        let shouldDismiss = vaccinationCentresList.isEmpty && followedCentresIds.isEmpty
        if shouldDismiss {
            delegate?.dismissViewController()
            return
        }
    }

    override internal func createHeadingCells(appointmentsCount: Int, availableCentresCount: Int, centresCount: Int) -> [CentresListCell] {
        let mainTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.followedCentresListTitle,
            topMargin: 25,
            bottomMargin: 0
        )
        return [.title(mainTitleViewData)]
    }

    override internal func getVaccinationCentres(for centres: [VaccinationCentre]) -> [VaccinationCentre] {
        return centres
            .filter({ followedCentresIds.contains($0.id) })
            .sorted(by: VaccinationCentre.sortedByAppointment)
    }

    override internal var departmentsToLoad: [String] {
       return userDefaults.followedCentres.map(\.key)
    }

    override internal func trackSearchResult(
        availableCentres: [VaccinationCentre],
        unavailableCentres: [VaccinationCentre]
    ) {
        // TODO: tracking
    }
}
