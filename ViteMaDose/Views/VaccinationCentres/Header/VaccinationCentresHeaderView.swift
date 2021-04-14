//
//  VaccinationCentresHeaderView.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 13/04/2021.
//

import UIKit

protocol VaccinationCentresHeaderViewModelProvider {
    var dosesCount: Int { get }
    var countyName: String { get }
    var availableCentresCount: Int { get }
    var allCentresCount: Int { get }
}

struct VaccinationCentresHeaderViewModel: VaccinationCentresHeaderViewModelProvider {
    var dosesCount: Int
    var countyName: String
    var availableCentresCount: Int
    var allCentresCount: Int
}

class VaccinationCentresHeaderView: UIView {
    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

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

        static let highlightedDosesTextColor: UIColor = .systemGreen
        static let highlightedCountyTextColor: UIColor = .mandy

        static let titleFirstPartText = "Nous avons trouvé"
        static let titleSecondPartText = "doses"
        static let titleThirdText = "pour le département"
        static let titleNoDoseText = "Nous n'avons pas trouvé de doses pour le département"
        static let subtitleText = "Liste des centres"

        static let availableCentresText = "Centres avec rendez-vous"
        static let allCentresText = "Centres trouvés au total"

        static let detailViewsCornerRadius: CGFloat = 15
    }

    func configure(with viewModel: VaccinationCentresHeaderViewModelProvider) {
        backgroundColor = .athensGray

        titelLabel.attributedText = createTitle(
            withDoses: viewModel.dosesCount,
            andCountyName: viewModel.countyName
        )

        subtitleLabel.text = Constant.subtitleText
        subtitleLabel.font = Constant.titleFont

        configureAvailableCentresView(viewModel)
        configureAllCentresView(viewModel)
    }

    private func createTitle(
        withDoses dosesCount: Int,
        andCountyName countyName: String
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont,
        ]

        guard dosesCount > 0 else {
            let title = NSMutableAttributedString(
                string:"\(Constant.titleNoDoseText) \(countyName)",
                attributes: attributes
            )
            title.setColorForText(textForAttribute: countyName, withColor: .mandy)
            return title
        }

        let dosesCountString = String(dosesCount)
        let titleString = "\(Constant.titleFirstPartText) \(dosesCountString) \(Constant.titleSecondPartText) \(Constant.titleThirdText) \(countyName)"
        let title = NSMutableAttributedString(
            string: titleString,
            attributes: attributes
        )
        title.setColorForText(textForAttribute: dosesCountString, withColor: .systemGreen)
        title.setColorForText(textForAttribute: countyName, withColor: .mandy)

        return title
    }

    // TODO: Refactor these into one function (or make a separated xib)

    private func configureAvailableCentresView(_ viewModel: VaccinationCentresHeaderViewModelProvider) {
        let checkMarkIcon =  UIImage(systemName: "checkmark")
        let crossMarkIcon = UIImage(systemName: "xmark")
        let hasDoses = viewModel.dosesCount > 0

        availableCentresIconImageView.image = hasDoses ? checkMarkIcon : crossMarkIcon
        availableCentresIconImageView.image = availableCentresIconImageView.image?.withTintColor(.white)
        availableCentresIconContainer.backgroundColor = hasDoses ? .systemGreen : .systemRed

        availableCentresIconContainer.setCornerRadius(availableCentresIconContainer.bounds.width / 2)
        availableCentresCountView.setCornerRadius(Constant.detailViewsCornerRadius)

        availableCentresCountLabel.text = String(viewModel.availableCentresCount)
        availableCentresDescriptionLabel.text = Constant.availableCentresText

        availableCentresCountLabel.font = Constant.titleFont
        availableCentresCountLabel.textColor = Constant.titleColor

        availableCentresDescriptionLabel.font = Constant.descriptionFont
        availableCentresDescriptionLabel.textColor = Constant.descriptionColor
    }

    private func configureAllCentresView(_ viewModel: VaccinationCentresHeaderViewModelProvider) {
        allCentresIconContainer.setCornerRadius(allCentresIconContainer.bounds.width / 2)
        allCentresCountView.setCornerRadius(Constant.detailViewsCornerRadius)

        allCentresCountLabel.text = String(viewModel.allCentresCount)
        allCentresDescriptionLabel.text = Constant.allCentresText

        allCentresCountLabel.font = Constant.titleFont
        allCentresDescriptionLabel.textColor = Constant.titleColor

        allCentresDescriptionLabel.font = Constant.descriptionFont
        allCentresDescriptionLabel.textColor = Constant.descriptionColor
    }
}
