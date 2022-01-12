// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

// MARK: - Centres Sort Options Cell View Data Provider

protocol CentresSortOptionsCellViewDataProvider {
    /// Matched to each segment of the `CentresSortOptionsCell` segmented control.
    var sortOption: CentresListSortOption { get }
    /// Use to deal with specific cases where some segments are not relevant
    var filterOption: CentresListFilterOption { get }
}

// MARK: - Centres Sort Options Cell View Data

public struct CentresSortOptionsCellViewData: CentresSortOptionsCellViewDataProvider, Hashable {
    let sortOption: CentresListSortOption
    let filterOption: CentresListFilterOption
}

// MARK: - Centres Sort Options Cell

final class CentresSortOptionsCell: UITableViewCell {
    @IBOutlet private var sortSegmentedControl: UISegmentedControl!
    var sortSegmentedControlHandler: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        contentView.backgroundColor = .athensGray
        selectionStyle = .none

        sortSegmentedControl.setTitle(
            Localization.Locations.SortOption.closest,
            forSegmentAt: CentresListSortOption.closest.index)
        sortSegmentedControl.setTitle(
            Localization.Locations.SortOption.fastest,
            forSegmentAt: CentresListSortOption.fastest.index)
        sortSegmentedControl.setTitle(
            Localization.Locations.SortOption.third_dose,
            forSegmentAt: CentresListSortOption.thirdDose.index)
    }

    /// Configures the `sortSegmentedControl` using the given `CentresSortOptionsCellViewData`.
    /// The configuration to apply epens also to the "kids first doses" filtering option.
    /// Indeed, there aren't any "third dose" for kids, that is the reason why the dedicated segment must be diabled.
    /// - Parameter viewData: The configuration to apply
    func configure(with viewData: CentresSortOptionsCellViewData) {

        // If the user ha chosen the "kids first doses" fitler option, move the use to another segmend if it was on the "third dose"
        // and disable the third segment.
        if viewData.filterOption == .kidsFirstDoses {
            if sortSegmentedControl.selectedSegmentIndex == CentresListSortOption.thirdDose.index {
                sortSegmentedControl.selectedSegmentIndex = CentresListSortOption.fastest.index
            } else {
                sortSegmentedControl.selectedSegmentIndex = viewData.sortOption.index
            }
            sortSegmentedControl.setEnabled(false, forSegmentAt: CentresListSortOption.thirdDose.index)

        // Select the suitable segment and ensure to have always the "third dose" segment enabled.
        } else {
            sortSegmentedControl.selectedSegmentIndex = viewData.sortOption.index
            sortSegmentedControl.setEnabled(true, forSegmentAt: CentresListSortOption.thirdDose.index)
        }
        sortSegmentedControl.sendActions(for: UIControl.Event.valueChanged)
    }

    @IBAction private func sortingSegmentChanged(_ sender: UISegmentedControl) {
        sortSegmentedControlHandler?(sender.selectedSegmentIndex)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sortSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    }
}
