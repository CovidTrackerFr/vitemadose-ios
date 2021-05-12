//
//  LocationSearchCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 17/04/2021.
//

import UIKit

protocol LocationSearchResultCellViewDataProvider {
    var name: String { get }
    var postCode: String? { get }
    var departmentCode: String? { get }
}

struct LocationSearchResultCellViewData: LocationSearchResultCellViewDataProvider, Hashable {
    let name: String
    let postCode: String?
    let departmentCode: String?
}

class LocationSearchResultCell: UITableViewCell {
    @IBOutlet private var codeLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var cellContainerView: UIView!
    @IBOutlet private var codeContainerView: UIView!

    private enum Constant {
        static let codeTextColor: UIColor = .white
        static let nameTextColor: UIColor = .label
        static let codeBackgroundColor: UIColor = .royalBlue
        static let cellBackgroundColor: UIColor = .tertiarySystemBackground
        static let labelsFont: UIFont = .rounded(ofSize: 18, weight: .bold)
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewData: LocationSearchResultCellViewDataProvider) {
        contentView.backgroundColor = .athensGray

        codeContainerView.backgroundColor = Constant.codeBackgroundColor
        cellContainerView.backgroundColor = Constant.cellBackgroundColor

        codeContainerView.setCornerRadius(Constant.viewsCornerRadius)
        cellContainerView.setCornerRadius(Constant.viewsCornerRadius)

        codeLabel.text = viewData.departmentCode
        nameLabel.text = viewData.name

        codeLabel.textColor = Constant.codeTextColor
        nameLabel.textColor = Constant.nameTextColor

        codeLabel.font = Constant.labelsFont
        nameLabel.font = Constant.labelsFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        codeLabel.text = nil
    }
}
