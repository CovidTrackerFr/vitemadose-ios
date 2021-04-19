//
//  CentresStatsCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
//

import UIKit

protocol CentresStatsCellViewDataProvider {
    var dosesCount: Int { get }
    var availableCentresCount: Int { get }
    var allCentresCount: Int { get }
}

struct CentresStatsCellViewData: CentresStatsCellViewDataProvider, Hashable {
    let dosesCount: Int
    let availableCentresCount: Int
    let allCentresCount: Int
}

class CentresStatsCell: UITableViewCell {

    @IBOutlet var availableCentresCountLabel: UILabel!
    @IBOutlet var availableCentresDescriptionLabel: UILabel!
    @IBOutlet var availableCentresIconContainer: UIView!
    @IBOutlet var availableCentresIconImageView: UIImageView!

    @IBOutlet var allCentresCountLabel: UILabel!
    @IBOutlet var allCentresDescriptionLabel: UILabel!
    @IBOutlet var allCentresIconContainer: UIView!

    @IBOutlet var availableCentresCountView: UIView!
    @IBOutlet var allCentresCountView: UIView!

    private enum Constant {
        static let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)
        static let titleColor: UIColor = .label

        static let descriptionFont: UIFont = .rounded(ofSize: 14, weight: .bold)
        static let descriptionColor: UIColor = .secondaryLabel

        static let availableCentresText = "Centres avec rendez-vous"
        static let allCentresText = "Centres trouvés au total"

        static let detailViewsCornerRadius: CGFloat = 15
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        contentView.backgroundColor = .athensGray
        selectionStyle = .none
    }

    func configure(with viewData: CentresStatsCellViewData) {
        configureAvailableCentresView(viewData)
        configureAllCentresView(viewData)
    }

    private func configureAvailableCentresView(_ viewData: CentresStatsCellViewData) {
        let checkMarkIcon =  UIImage(systemName: "checkmark")
        let crossMarkIcon = UIImage(systemName: "xmark")
        let hasDoses = viewData.dosesCount > 0

        availableCentresIconImageView.image = hasDoses ? checkMarkIcon : crossMarkIcon
        availableCentresIconImageView.image = availableCentresIconImageView.image?.withTintColor(.white)
        availableCentresIconContainer.backgroundColor = hasDoses ? .systemGreen : .systemRed

        availableCentresIconContainer.setCornerRadius(availableCentresIconContainer.bounds.width / 2)
        availableCentresCountView.setCornerRadius(Constant.detailViewsCornerRadius)

        availableCentresCountLabel.text = String(viewData.availableCentresCount)
        availableCentresDescriptionLabel.text = Constant.availableCentresText

        availableCentresCountLabel.font = Constant.titleFont
        availableCentresCountLabel.textColor = Constant.titleColor

        availableCentresDescriptionLabel.font = Constant.descriptionFont
        availableCentresDescriptionLabel.textColor = Constant.descriptionColor
    }

    private func configureAllCentresView(_ viewData: CentresStatsCellViewData) {
        allCentresIconContainer.setCornerRadius(allCentresIconContainer.bounds.width / 2)
        allCentresCountView.setCornerRadius(Constant.detailViewsCornerRadius)

        allCentresCountLabel.text = String(viewData.allCentresCount)
        allCentresDescriptionLabel.text = Constant.allCentresText

        allCentresCountLabel.font = Constant.titleFont
        allCentresDescriptionLabel.textColor = Constant.titleColor

        allCentresDescriptionLabel.font = Constant.descriptionFont
        allCentresDescriptionLabel.textColor = Constant.descriptionColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        availableCentresIconImageView.image = nil
        availableCentresCountLabel.text = nil
        availableCentresDescriptionLabel.text = nil
        allCentresCountLabel.text = nil
        allCentresDescriptionLabel.text = nil
    }

}
