//
//  CountySelectionTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 17/04/2021.
//

import UIKit

protocol HomeCountySelectionCellViewDataProvider {
    var searchBarText: String { get }
}

struct HomeCountySelectionViewData: HomeCountySelectionCellViewDataProvider, Hashable {
    let searchBarText = "select_area".localized()
}

class HomeCountySelectionCell: UITableViewCell {
    
    @IBOutlet private var searchBarView: UIView!
    @IBOutlet private var searchBarTitle: UILabel!

    private enum Constant {
        static let searchBarFont: UIFont = .rounded(ofSize: 16, weight: .medium)
        static let searchBarViewCornerRadius: CGFloat = 15.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        searchBarView.backgroundColor = .tertiarySystemBackground


        searchBarTitle.font = Constant.searchBarFont

        let shadow = UIView.Shadow(
            color: .label,
            opacity: 0.05,
            offset: CGSize(width: 0, height: 5),
            radius: 5
        )
        searchBarView.setCornerRadius(Constant.searchBarViewCornerRadius, withShadow: shadow)
    }

    func configure(with viewData: HomeCountySelectionCellViewDataProvider = HomeCountySelectionViewData()) {
        searchBarTitle.text = viewData.searchBarText
    }
}
