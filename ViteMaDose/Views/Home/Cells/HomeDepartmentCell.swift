//
//  HomeDepartmentCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 11/04/2021.
//

import UIKit

protocol HomeDepartmentCellViewDataProvider: LocationSearchResultCellViewDataProvider {
    var titleText: String? { get }
}

struct HomeDepartmentCellViewData: HomeDepartmentCellViewDataProvider, Hashable, Identifiable {
    let id = UUID()
    let titleText: String?
    let name: String
    let code: String
}

class HomeDepartmentCell: LocationSearchResultCell {
    @IBOutlet var titleLabel: UILabel!

     func configure(with viewData: HomeDepartmentCellViewDataProvider) {
        super.configure(with: viewData)

        titleLabel.isHidden = viewData.titleText == nil
        titleLabel.text = viewData.titleText
        titleLabel.font = .rounded(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
