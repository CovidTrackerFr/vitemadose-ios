//
//  HomeSearchResultCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 11/04/2021.
//

import UIKit

protocol HomeSearchResultCellViewDataProvider: LocationSearchResultCellViewDataProvider {
    var titleText: String? { get }
}

struct HomeSearchResultCellViewData: HomeSearchResultCellViewDataProvider, Hashable {
    let titleText: String?
    let name: String
    let postCode: String?
    let departmentCode: String
}

class HomeSearchResultCell: LocationSearchResultCell {
    @IBOutlet var titleLabel: UILabel!

     func configure(with viewData: HomeSearchResultCellViewDataProvider) {
        super.configure(with: viewData)
        titleLabel.isHidden = viewData.titleText == nil
        titleLabel.text = viewData.titleText
        titleLabel.font = .rounded(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        if viewData.titleText != nil {
            self.accessibilityLabel = Localization.A11y.VoiceOver.HomeScreen.recent_searches
                + " "
                + Localization.A11y.VoiceOver.HomeScreen.see_department_results
                + " "
                + viewData.name
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
