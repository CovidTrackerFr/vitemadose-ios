//
//  CountyCellTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 11/04/2021.
//

import UIKit

protocol HomeCountyCellViewDataProvider: CountyCellViewDataProvider {
    var titleText: String? { get }
}

struct HomeCountyCellViewData: HomeCountyCellViewDataProvider, Hashable {
    var titleText: String?
    var countyName: String
    var countyCode: String
}

class HomeCountyCell: CountyCell {
    @IBOutlet var titleLabel: UILabel!

     func configure(with viewData: HomeCountyCellViewDataProvider) {
        super.configure(with: viewData)

        titleLabel.isHidden = viewData.titleText == nil
        titleLabel.text = viewData.titleText
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
