//
//  CountyCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 17/04/2021.
//

import UIKit

protocol CountyCellViewDataProvider {
    var countyName: String { get }
    var countyCode: String { get }
}

struct CountyCellViewData: CountyCellViewDataProvider, Hashable {
    var titleText: String?
    var countyName: String
    var countyCode: String
}

class CountyCell: UITableViewCell {
    @IBOutlet private var countyCodeLabel: UILabel!
    @IBOutlet private var countyNameLabel: UILabel!
    @IBOutlet private var countyContainerView: UIView!
    @IBOutlet private var countyCodeContainerView: UIView!

    private enum Constant {
        static let countyCodeTextColor: UIColor = .white
        static let countyNameTextColor: UIColor = .label
        static let countyCodeBackgroundColor: UIColor = .royalBlue
        static let cellBackgrounColor: UIColor = .tertiarySystemBackground
        static let labelsFont: UIFont = .rounded(ofSize: 18, weight: .bold)
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewData: CountyCellViewDataProvider) {
        contentView.backgroundColor = .athensGray

        countyCodeContainerView.backgroundColor = Constant.countyCodeBackgroundColor
        countyContainerView.backgroundColor = Constant.cellBackgrounColor

        countyCodeContainerView.setCornerRadius(Constant.viewsCornerRadius)
        countyContainerView.setCornerRadius(Constant.viewsCornerRadius)

        countyCodeLabel.text = viewData.countyCode
        countyNameLabel.text = viewData.countyName

        countyCodeLabel.textColor = Constant.countyCodeTextColor
        countyNameLabel.textColor = Constant.countyNameTextColor

        countyCodeLabel.font = Constant.labelsFont
        countyNameLabel.font = Constant.labelsFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        countyNameLabel.text = nil
        countyCodeLabel.text = nil
    }
}
