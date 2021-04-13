//
//  VaccinationBookingTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 12/04/2021.
//

import UIKit

protocol VaccinationBookingCellViewModelProvider {
    var dayText: String? { get}
    var timeText: String? { get }
    var addressNameText: String? { get }
    var addressText: String? { get }
    var phoneText: String? { get }
    var bookingButtonText: NSMutableAttributedString { get }
    var vaccineTypesText: String? { get }
    var dosesText: String? { get }
    var isAvailable: Bool { get }
    var url: URL? { get }
    var partnerLogo: UIImage? { get }
}

struct VaccinationBookingCellViewModel: VaccinationBookingCellViewModelProvider {
    var dayText: String?
    var timeText: String?
    var addressNameText: String?
    var addressText: String?
    var phoneText: String?
    var bookingButtonText: NSMutableAttributedString
    var vaccineTypesText: String?
    var dosesText: String?
    var isAvailable: Bool
    var url: URL?
    var partnerLogo: UIImage?
}

class VaccinationBookingTableViewCell: UITableViewCell {
    @IBOutlet var dateContainer: UIStackView!
    @IBOutlet var dateIconContainer: UIView!
    @IBOutlet private var dateLabel: UILabel!

    @IBOutlet var addressNameContainer: UIStackView!
    @IBOutlet var addressNameIconContainer: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!

    @IBOutlet var phoneNumberContrainer: UIStackView!
    @IBOutlet var phoneNumberIconContainer: UIView!
    @IBOutlet private var phoneLabel: UILabel!

    @IBOutlet var vaccineTypesContainer: UIStackView!
    @IBOutlet private var vaccineTypesLabel: UILabel!

    @IBOutlet var dosesContainer: UIStackView!
    @IBOutlet var vaccineTypesIconContainer: UIView!
    @IBOutlet var dosesLabel: UILabel!
    @IBOutlet var partnerLogoImageView: UIImageView!

    @IBOutlet private var bookingbutton: UIButton!
    @IBOutlet private var cellContentView: UIView!

    private lazy var iconContainers: [UIView] = [
        dateIconContainer,
        addressNameIconContainer,
        phoneNumberIconContainer,
        vaccineTypesIconContainer,
    ]

    var bookingButtonTapHandler: (() -> Void)?

    private enum Constant {
        static let cellContentViewCornerRadius: CGFloat = 15
        static let bookingButtonCornerRadius: CGFloat = 8
        static let iconContainersCornerRadius: CGFloat = 5

        static let dateFont: UIFont = .systemFont(ofSize: 14, weight: .medium)
        static let dateHighlightedFont: UIFont = .systemFont(ofSize: 16, weight: .heavy)
        static let labelPrimaryFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
        static let labelPrimaryColor: UIColor = .label
        static let labelSecondaryColor: UIColor = .secondaryLabel
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .athensGray
        cellContentView.backgroundColor = .tertiarySystemBackground
        bookingbutton.backgroundColor = .royalBlue
        bookingbutton.setCornerRadius(Constant.bookingButtonCornerRadius)
        cellContentView.setCornerRadius(Constant.cellContentViewCornerRadius)
    }

    func configure(with viewModel: VaccinationBookingCellViewModelProvider?) {
        guard let viewModel = viewModel else {
            preconditionFailure("ViewModel is required")
        }

        dateLabel.attributedText = createDateText(
            dayText: viewModel.dayText,
            timeText: viewModel.timeText,
            isAvailable: viewModel.isAvailable
        )

        nameLabel.text = viewModel.addressNameText
        nameLabel.font = Constant.labelPrimaryFont
        nameLabel.textColor = Constant.labelPrimaryColor

        addressLabel.text = viewModel.addressText
        addressLabel.textColor = Constant.labelSecondaryColor

        phoneNumberContrainer.isHidden = viewModel.phoneText == nil
        phoneLabel.text = viewModel.phoneText
        phoneLabel.font = Constant.labelPrimaryFont
        phoneLabel.textColor = Constant.labelPrimaryColor

        vaccineTypesContainer.isHidden = viewModel.vaccineTypesText == nil
        vaccineTypesLabel.text = viewModel.vaccineTypesText
        vaccineTypesLabel.font = Constant.labelPrimaryFont
        vaccineTypesLabel.textColor = Constant.labelPrimaryColor

        dosesLabel.text = viewModel.dosesText
        dosesLabel.font = Constant.labelPrimaryFont
        dosesLabel.textColor = Constant.labelPrimaryColor

        bookingbutton.backgroundColor = viewModel.isAvailable ? .royalBlue : .darkGray
        bookingbutton.setTitleColor(.white, for: .normal)
        bookingbutton.setAttributedTitle(viewModel.bookingButtonText, for: .normal)
        bookingbutton.addTarget(
            self,
            action: #selector(didTapBookButton),
            for: .touchUpInside
        )

        dosesLabel.textAlignment = .center
        partnerLogoImageView.isHidden = viewModel.partnerLogo == nil
        if let partnerLogo = viewModel.partnerLogo {
            let tintedLogo = partnerLogo.tint(with: .systemGray)
            partnerLogoImageView.image = tintedLogo
            dosesLabel.textAlignment = .right
        }

        setCornerRadius(to: Constant.iconContainersCornerRadius, for: iconContainers)
    }

    @objc private func didTapBookButton() {
        bookingButtonTapHandler?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTextFor([
            dateLabel,
            nameLabel,
            addressLabel,
            phoneLabel,
            vaccineTypesLabel,
            dosesLabel
        ])
        bookingbutton.setTitle(nil, for: .normal)
    }

    private func createDateText(
        dayText: String?,
        timeText: String?,
        isAvailable: Bool
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.labelPrimaryColor,
            NSAttributedString.Key.font: Constant.labelPrimaryFont,
        ]

        guard isAvailable else {
            return NSMutableAttributedString(
                string: "Aucun rendez-vous",
                attributes: attributes
            )
        }

        guard let dayText = dayText, let timeText = timeText else {
            return NSMutableAttributedString.init(
                string: "Date Indisponible",
                attributes: attributes
            )
        }

        let dateString = "Le \(dayText) à partir de \(timeText)"
        let dateText = NSMutableAttributedString(
            string: dateString,
            attributes: attributes
        )

        dateText.setFontForText(textForAttribute: dayText, withFont: .systemFont(ofSize: 16, weight: .heavy))
        dateText.setFontForText(textForAttribute: timeText, withFont: .systemFont(ofSize: 16, weight: .heavy))

        return dateText
    }

    private func setCornerRadius(to radius: CGFloat, for views: [UIView]) {
        views.forEach{ $0.setCornerRadius(radius) }
    }

    private func resetTextFor(_ labels: [UILabel]) {
        labels.forEach{ $0.text = nil }
    }
}
