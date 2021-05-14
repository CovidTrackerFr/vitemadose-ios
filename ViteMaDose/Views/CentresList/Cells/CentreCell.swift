//
//  CentreCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 12/04/2021.
//

import UIKit

// MARK: - CentreViewDataProvider

protocol CentreViewDataProvider {
    var dayText: String? { get }
    var timeText: String? { get }
    var addressNameText: String? { get }
    var addressText: String? { get }
    var phoneText: String? { get }
    var bookingButtonText: String { get }
    var vaccineTypesText: String? { get }
    var appointmentsCount: Int? { get }
    var isAvailable: Bool { get }
    var partnerLogo: UIImage? { get }
    var isChronoDose: Bool { get }
    var notificationsType: FollowedCentre.NotificationsType? { get }
}

// MARK: - CentreViewData

public struct CentreViewData: CentreViewDataProvider, Hashable, Identifiable {
    public let id: String
    let dayText: String?
    let timeText: String?
    let addressNameText: String?
    let addressText: String?
    let phoneText: String?
    let bookingButtonText: String
    let vaccineTypesText: String?
    let appointmentsCount: Int?
    let isAvailable: Bool
    let partnerLogo: UIImage?
    let isChronoDose: Bool
    let notificationsType: FollowedCentre.NotificationsType?
}

// MARK: - CentreCell

final class CentreCell: UITableViewCell {

    @IBOutlet weak private var dateContainer: UIStackView!
    @IBOutlet weak private var dateIconContainer: UIView!
    @IBOutlet weak private var dateLabel: UILabel!

    @IBOutlet weak private(set) var addressNameContainer: UIStackView!
    @IBOutlet weak private var addressNameIconContainer: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var addressLabel: UILabel!

    @IBOutlet weak private var phoneNumberContainer: UIStackView!
    @IBOutlet weak private var phoneNumberIconContainer: UIView!
    @IBOutlet weak private var phoneButton: UIButton!

    @IBOutlet weak private var vaccineTypesContainer: UIStackView!
    @IBOutlet weak private var vaccineTypesLabel: UILabel!

    @IBOutlet weak private var vaccineTypesIconContainer: UIView!
    @IBOutlet weak private var appointmentsLabel: UILabel!

    @IBOutlet weak private var bookingButton: UIButton!
    @IBOutlet weak private var cellContentView: UIView!

    @IBOutlet weak private var vaccineTypeImageView: UIImageView!

    @IBOutlet weak var chronoDoseViewContainer: UIView!
    @IBOutlet weak var chronoDoseLabel: UILabel!

    @IBOutlet weak var followCentreButton: UIButton!

    private lazy var iconContainers: [UIView] = [
        dateIconContainer,
        addressNameIconContainer,
        phoneNumberIconContainer,
        vaccineTypesIconContainer
    ]

    var addressTapHandler: (() -> Void)?
    var phoneNumberTapHandler: (() -> Void)?
    var bookingButtonTapHandler: (() -> Void)?
    var followButtonTapHandler: (() -> Void)?

    private enum Constant {
        static let cellContentViewCornerRadius: CGFloat = 15
        static let bookingButtonCornerRadius: CGFloat = 8
        static let iconContainersCornerRadius: CGFloat = 5

        static let dateFont: UIFont = .systemFont(ofSize: 14, weight: .medium)
        static let dateHighlightedFont: UIFont = .systemFont(ofSize: 16, weight: .heavy)
        static let labelPrimaryFont: UIFont = .systemFont(ofSize: 16, weight: .medium)
        static let labelPrimaryColor: UIColor = .label
        static let labelSecondaryColor: UIColor = .secondaryLabel
        static let appointmentsLabelFont: UIFont = .systemFont(ofSize: 14, weight: .medium)
    }

    // MARK: - View lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .athensGray
        cellContentView.backgroundColor = .tertiarySystemBackground
        bookingButton.backgroundColor = .royalBlue
        bookingButton.setCornerRadius(Constant.bookingButtonCornerRadius)
        cellContentView.setCornerRadius(Constant.cellContentViewCornerRadius)
        vaccineTypeImageView.image = UIImage(systemName: "cube.box.fill")
    }

    func configure(with viewData: CentreViewData) {
        configureBookButton(viewData)
        configurePhoneNumberView(viewData)
        configureChronoDoseView(viewData)
        configureFollowCentreButton(viewData)

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
        configureAppointmentsLabel(appointmentsCount: viewData.appointmentsCount, partnerLogo: viewData.partnerLogo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTextFor([
            dateLabel,
            nameLabel,
            addressLabel,
            vaccineTypesLabel,
            appointmentsLabel
        ])
        phoneButton.setTitle(nil, for: .normal)
        bookingButton.setTitle(nil, for: .normal)
        followCentreButton.setImage(nil, for: .normal)
    }

    // MARK: - Actions

    @objc private func didTapAddress() {
        addressTapHandler?()
    }

    @objc private func didTapPhoneNumber() {
        phoneNumberTapHandler?()
    }

    @objc private func didTapBookButton() {
        bookingButtonTapHandler?()
    }

    @objc private func didTapFollowCentreButton() {
        followButtonTapHandler?()
    }

    // MARK: - Helpers

    private func createDateText(
        dayText: String?,
        timeText: String?,
        isAvailable: Bool
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.labelPrimaryColor,
            NSAttributedString.Key.font: Constant.labelPrimaryFont
        ]
        let boldFont: UIFont = .systemFont(ofSize: 16, weight: .heavy)
        guard isAvailable else {
            let titleString = Localization.Location.no_appointment
            let unavailableAttributedString = NSMutableAttributedString(
                string: titleString,
                attributes: attributes
            )
            unavailableAttributedString.setFontForText(textForAttribute: titleString, withFont: boldFont)
            return unavailableAttributedString
        }

        guard let dayText = dayText, let timeText = timeText else {
            return NSMutableAttributedString.init(
                string: Localization.Location.unavailable_date,
                attributes: attributes
            )
        }

        let dateString = Localization.Location.date.format(dayText, timeText)
        let dateText = NSMutableAttributedString(
            string: dateString,
            attributes: attributes
        )

        dateText.setFontForText(textForAttribute: dayText, withFont: boldFont)
        dateText.setFontForText(textForAttribute: timeText, withFont: boldFont)

        return dateText
    }

    private func configureAppointmentsLabel(
        appointmentsCount: Int?,
        partnerLogo: UIImage?
    ) {
        let attributes = [
            NSAttributedString.Key.font: Constant.appointmentsLabelFont,
            NSAttributedString.Key.foregroundColor: Constant.labelSecondaryColor
        ]

        guard let appointmentsCount = appointmentsCount, appointmentsCount > 0 else {
            appointmentsLabel.isHidden = true
            return
        }

        appointmentsLabel.isHidden = false
        let appointmentsText: String = Localization.Locations.appointments.format(appointmentsCount) + String.space

        guard let logo = partnerLogo?.tint(with: .systemGray) else {
            appointmentsLabel.attributedText = NSAttributedString(string: appointmentsText, attributes: attributes)
            return
        }

        let attachmentLogo = NSTextAttachment(rightImage: logo, height: 20, offset: 10)
        let logoString = NSAttributedString(attachment: attachmentLogo)
        let appointmentsAndLogoString = NSMutableAttributedString(string: appointmentsText, attributes: attributes)
        appointmentsAndLogoString.append(logoString)

        appointmentsLabel.attributedText = appointmentsAndLogoString
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
                NSAttributedString.Key.foregroundColor: Constant.labelPrimaryColor,
                NSAttributedString.Key.font: Constant.labelPrimaryFont,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
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
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ]
        )

        bookingButtonAttributedText.append(NSAttributedString(attachment: imageAttachment))

        let availableButtonColor: UIColor = viewData.isChronoDose ? .mandy : .royalBlue
        bookingButton.backgroundColor = viewData.isAvailable ? availableButtonColor : .darkGray
        bookingButton.setTitleColor(.white, for: .normal)
        bookingButton.setAttributedTitle(bookingButtonAttributedText, for: .normal)
        bookingButton.addTarget(
            self,
            action: #selector(didTapBookButton),
            for: .touchUpInside
        )
    }

    private func configureChronoDoseView(_ viewData: CentreViewData) {
        guard viewData.isChronoDose else {
            chronoDoseViewContainer.isHidden = true
            return
        }

        chronoDoseViewContainer.isHidden = false
        chronoDoseViewContainer.clipsToBounds = false
        chronoDoseViewContainer.layer.cornerRadius = 15.0
        chronoDoseViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        chronoDoseLabel.text = Localization.Location.chronodoses_available
    }

    private func configureFollowCentreButton(_ viewData: CentreViewData) {
        followCentreButton.isHidden = viewData.notificationsType == nil
        guard let notificationsType = viewData.notificationsType else {
            return
        }

        switch notificationsType {
        case .all:
            followCentreButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
            followCentreButton.backgroundColor = .royalBlue
        case .chronodoses:
            followCentreButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
            followCentreButton.backgroundColor = .mandy
        case .none:
            followCentreButton.setImage(UIImage(systemName: "bell.slash.fill"), for: .normal)
            followCentreButton.backgroundColor = .darkGray
        }

        followCentreButton.setCornerRadius(8.0)
        followCentreButton.addTarget(
            self,
            action: #selector(didTapFollowCentreButton),
            for: .touchUpInside
        )
    }

    private func setCornerRadius(to radius: CGFloat, for views: [UIView]) {
        views.forEach { $0.setCornerRadius(radius) }
    }

    private func resetTextFor(_ labels: [UILabel]) {
        labels.forEach { $0.text = nil }
    }
}
