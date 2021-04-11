//
//  CountyCellTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 11/04/2021.
//

import UIKit

class CountyCellTableViewCell: UITableViewCell {

    @IBOutlet private var countyCodeLabel: UILabel!
    @IBOutlet private var countyNameLabel: UILabel!
    @IBOutlet private var cellContainerView: UIView!
    @IBOutlet private var countyCodeContainerView: UIView!

    private enum Constant {
        static let countyCodeTextColor: UIColor = .white
        static let countyNameTextColor: UIColor = .label
        static let countyCodeBackgroundColor: UIColor = .royalBlue
        static let cellBackgrounColor: UIColor = .tertiarySystemBackground
        static let labelsFont: UIFont = .rounded(ofSize: 18, weight: .bold)
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewModel: CountyCellViewModelProvider) {
        contentView.backgroundColor = .athensGray
        countyCodeContainerView.backgroundColor = Constant.countyCodeBackgroundColor
        cellContainerView.backgroundColor = Constant.cellBackgrounColor

        countyCodeContainerView.setCornerRadius(Constant.viewsCornerRadius)
        cellContainerView.setCornerRadius(Constant.viewsCornerRadius)

        countyCodeLabel.text = viewModel.countyCode
        countyNameLabel.text = viewModel.countyName

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
