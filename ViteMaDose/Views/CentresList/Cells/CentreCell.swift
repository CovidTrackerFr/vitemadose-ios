//
//  CentreCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 12/04/2021.
//

import UIKit

protocol CentreViewDataProvider {
    var dayText: String? { get }
    var timeText: String? { get }
    var addressNameText: String? { get }
    var addressText: String? { get }
    var phoneText: String? { get }
    var bookingButtonText: String { get }
    var vaccineTypesText: String? { get }
    var dosesCount: Int? { get }
    var isAvailable: Bool { get }
    var url: URL? { get }
    var partnerLogo: UIImage? { get }
}

struct CentreViewData: CentreViewDataProvider, Hashable {
    let dayText: String?
    let timeText: String?
    let addressNameText: String?
    let addressText: String?
    let phoneText: String?
    let bookingButtonText: String
    let vaccineTypesText: String?
    let dosesCount: Int?
    let isAvailable: Bool
    let url: URL?
    let partnerLogo: UIImage?
}

class CentreCell: UITableViewCell {
    @IBOutlet var dateContainer: UIStackView!
    @IBOutlet var dateIconContainer: UIView!
    @IBOutlet private var dateLabel: UILabel!

    @IBOutlet var addressNameContainer: UIStackView!
    @IBOutlet var addressNameIconContainer: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!

    @IBOutlet var phoneNumberContainer: UIStackView!
    @IBOutlet var phoneNumberIconContainer: UIView!
    @IBOutlet private var phoneButton: UIButton!

    @IBOutlet var vaccineTypesContainer: UIStackView!
    @IBOutlet private var vaccineTypesLabel: UILabel!

    @IBOutlet var vaccineTypesIconContainer: UIView!
    @IBOutlet var dosesLabel: UILabel!

    @IBOutlet private var bookingButton: UIButton!
    @IBOutlet private var cellContentView: UIView!

    private lazy var iconContainers: [UIView] = [
        dateIconContainer,
        addressNameIconContainer,
        phoneNumberIconContainer,
        vaccineTypesIconContainer,
    ]

    var addressTapHandler: (() -> Void)?
    var phoneNumberTapHandler: (() -> Void)?
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
        static let dosesLabelFont: UIFont = .systemFont(ofSize: 14, weight: .medium)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .athensGray
        cellContentView.backgroundColor = .tertiarySystemBackground
        bookingButton.backgroundColor = .royalBlue
        bookingButton.setCornerRadius(Constant.bookingButtonCornerRadius)
        cellContentView.setCornerRadius(Constant.cellContentViewCornerRadius)
    }

    func configure(with viewData: CentreViewData) {
        configureBookButton(viewData)
        configurePhoneNumberView(viewData)

        dateLabel.attributedText = createDateText(
            dayText: viewData.dayText,
            timeText: viewData.timeText,
            isAvailable: viewData.isAvailable
        )

        nameLabel.text = viewData.addressNameText
        nameLabel.font = Constant.labelPrimaryFont
        nameLabel.textColor = Constant.labelPrimaryColor

        addressLabel.text = viewData.addressText
        addressLabel.textColor = Constant.labelSecondaryColor

        let addressTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapAddress)
        )
        addressNameContainer.addGestureRecognizer(addressTapGesture)

        vaccineTypesContainer.isHidden = viewData.vaccineTypesText == nil
        vaccineTypesLabel.text = viewData.vaccineTypesText
        vaccineTypesLabel.font = Constant.labelPrimaryFont
        vaccineTypesLabel.textColor = Constant.labelPrimaryColor

        setCornerRadius(to: Constant.iconContainersCornerRadius, for: iconContainers)
        configureDosesLabel(dosesCount: viewData.dosesCount, partnerLogo: viewData.partnerLogo)
    }

    @objc private func didTapAddress() {
        addressTapHandler?()
    }

    @objc private func didTapPhoneNumber() {
        phoneNumberTapHandler?()
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
            vaccineTypesLabel,
            dosesLabel
        ])
        phoneButton.setTitle(nil, for: .normal)
        bookingButton.setTitle(nil, for: .normal)
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

    private func configureDosesLabel(
        dosesCount: Int?,
        partnerLogo: UIImage?
    ) {
        let attributes = [
            NSAttributedString.Key.font: Constant.dosesLabelFont,
            NSAttributedString.Key.foregroundColor: Constant.labelSecondaryColor,
        ]

        guard let dosesCount = dosesCount, dosesCount > 0 else {
            dosesLabel.isHidden = true
            return
        }

        dosesLabel.isHidden = false
        let dosesText: String = dosesCount > 1 ? String("\(dosesCount) doses ") : String("\(dosesCount) dose ")

        guard let logo = partnerLogo?.tint(with: .systemGray) else {
            dosesLabel.attributedText = NSAttributedString(string: dosesText, attributes: attributes)
            return
        }

        let attachmentLogo = NSTextAttachment(rightImage: logo, height: 20, offset: 10)
        let logoString = NSAttributedString(attachment: attachmentLogo)
        let dosesAndLogoString = NSMutableAttributedString(string: dosesText, attributes: attributes)
        dosesAndLogoString.append(logoString)

        dosesLabel.attributedText = dosesAndLogoString
    }

    private func configurePhoneNumberView(_ viewData: CentreViewData) {
        guard let phoneNumber = viewData.phoneText else {
            phoneNumberContainer.isHidden = true
            return
        }

        phoneNumberContainer.isHidden = false

        let phoneButtonAttributedText = NSMutableAttributedString(
            string: phoneNumber,
            attributes: [
                NSAttributedString.Key.foregroundColor : Constant.labelPrimaryColor,
                NSAttributedString.Key.font : Constant.labelPrimaryFont,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        )

        phoneButton.backgroundColor = .clear
        phoneButton.setAttributedTitle(phoneButtonAttributedText, for: .normal)
        phoneButton.addTarget(
            self,
            action: #selector(didTapPhoneNumber),
            for: .touchUpInside
        )
    }

    private func configureBookButton(_ viewData: CentreViewData) {
        let imageAttachment = NSTextAttachment()
        let iconImage = UIImage(
            systemName: "arrow.up.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        )
        imageAttachment.image = iconImage?.withTintColor(.white, renderingMode: .alwaysOriginal)

        let bookingButtonAttributedText = NSMutableAttributedString(
            string: viewData.bookingButtonText,
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .semibold),
            ]
        )

        bookingButtonAttributedText.append(NSAttributedString(attachment: imageAttachment))

        bookingButton.backgroundColor = viewData.isAvailable ? .royalBlue : .darkGray
        bookingButton.setTitleColor(.white, for: .normal)
        bookingButton.setAttributedTitle(bookingButtonAttributedText, for: .normal)
        bookingButton.addTarget(
            self,
            action: #selector(didTapBookButton),
            for: .touchUpInside
        )
    }

    private func setCornerRadius(to radius: CGFloat, for views: [UIView]) {
        views.forEach{ $0.setCornerRadius(radius) }
    }

    private func resetTextFor(_ labels: [UILabel]) {
        labels.forEach{ $0.text = nil }
    }
}
