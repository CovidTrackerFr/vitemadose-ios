//
//  CentresSortOptionCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 06/05/2021.
//

import UIKit

protocol CentresSortOptionsCellViewDataProvider {
    var sortOption: CentresListSortOption { get }
}

public struct CentresSortOptionsCellViewData: CentresSortOptionsCellViewDataProvider, Hashable {
    let sortOption: CentresListSortOption
}

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
            forSegmentAt: CentresListSortOption.closest.index
        )
        sortSegmentedControl.setTitle(
            Localization.Locations.SortOption.fastest,
            forSegmentAt: CentresListSortOption.fastest.index)
    }

    func configure(with viewData: CentresSortOptionsCellViewData) {
        sortSegmentedControl.selectedSegmentIndex = viewData.sortOption.index
    }

    @IBAction private func sortingSegmentChanged(_ sender: UISegmentedControl) {
        sortSegmentedControlHandler?(sender.selectedSegmentIndex)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sortSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    }
}
