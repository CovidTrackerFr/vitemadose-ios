//
//  CreditCell.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import UIKit
import Kingfisher

protocol CreditCellViewDataProvider {
    var creditName: String { get }
    var creditImage: String { get }
}

struct CreditCellViewData: CreditCellViewDataProvider, Hashable {
    var titleText: String?
    var creditName: String
    var creditImage: String
}

class CreditCell: UITableViewCell {
    @IBOutlet private var creditImageView: UIImageView!
    @IBOutlet private var creditNameLabel: UILabel!
    @IBOutlet private var creditContainerView: UIView!

    private enum Constant {
        static let creditNameTextColor: UIColor = .label
        static let creditImageBackgroundColor: UIColor = .royalBlue
        static let cellBackgrounColor: UIColor = .tertiarySystemBackground
        static let labelsFont: UIFont = .rounded(ofSize: 18, weight: .bold)
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewData: CreditCellViewDataProvider) {
        contentView.backgroundColor = .athensGray

        creditImageView.backgroundColor = Constant.creditImageBackgroundColor
        creditContainerView.backgroundColor = Constant.cellBackgrounColor

        creditImageView.setCornerRadius(Constant.viewsCornerRadius)
        creditContainerView.setCornerRadius(Constant.viewsCornerRadius)

        creditImageView.kf.setImage(with: URL(string: viewData.creditImage))
        creditNameLabel.text = viewData.creditName

        creditNameLabel.textColor = Constant.creditNameTextColor

        creditNameLabel.font = Constant.labelsFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        creditNameLabel.text = nil
        creditImageView.kf.cancelDownloadTask()
        creditImageView.image = nil
    }
}
