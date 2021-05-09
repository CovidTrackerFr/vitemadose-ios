//
//  FollowedCentresViewModel.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 08/05/2021.
//

import Foundation

final class FollowedCentresViewModel: CentresListViewModel {

    override var shouldFooterText: Bool {
        return false
    }

    override var sortOption: CentresListSortOption {
        return .fastest
    }

    init() {
        super.init(searchResult: nil)
    }

    override func reloadTableView(animated: Bool) {
        super.reloadTableView(animated: animated)
        if vaccinationCentresList.isEmpty {
            delegate?.dismissViewController()
        }
    }

    override internal func createHeadingCells(appointmentsCount: Int, availableCentresCount: Int, centresCount: Int) -> [CentresListCell] {
        let mainTitleViewData = HomeTitleCellViewData(
            titleText: CentresTitleCell.followedCentresListTitle,
            topMargin: 25,
            bottomMargin: 0
        )
        var cells: [CentresListCell] = [ .title(mainTitleViewData)]

        if !vaccinationCentresList.isEmpty {
            let statsCellViewData = CentresStatsCellViewData(
                appointmentsCount: appointmentsCount,
                availableCentresCount: availableCentresCount,
                allCentresCount: centresCount
            )
            cells.append(.stats(statsCellViewData))
        }

        return cells
    }

    override internal func getVaccinationCentres(
        for centres: [VaccinationCentre],
        sortOption: CentresListSortOption
    ) -> [VaccinationCentre] {
        let followedCentresIds = userDefaults.followedCentres.flatMap({ (element) in
            return element.value.map(\.id)
        })
        return centres
            .filter({ followedCentresIds.contains($0.id) })
            .sorted(by: VaccinationCentre.sortedByAppointment)
    }

    override internal func departmentsToLoad() -> [String] {
       return userDefaults.followedCentres.map(\.key)
    }

    override internal func trackSearchResult(
        availableCentres: [VaccinationCentre],
        unavailableCentres: [VaccinationCentre]
    ) {
        // TODO: tracking
    }
}
