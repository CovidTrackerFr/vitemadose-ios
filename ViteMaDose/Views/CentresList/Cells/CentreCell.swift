// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

// MARK: - Centre View Data Provider

protocol CentreViewDataProvider {
    var dayText: String? { get }
    var timeText: String? { get }
    var addressNameText: String? { get }
    var addressText: String? { get }
    var phoneText: String? { get }
    var bookingButtonText: String { get }
    var vaccineTypesTexts: AccessibilityString { get }
    var centerTypeText: String? { get }
    var appointmentsCount: Int? { get }
    var isAvailable: Bool { get }
    var partnerLogo: UIImage? { get }
    var notificationsType: FollowedCentre.NotificationsType? { get }
}

// MARK: - Centre View Data

public struct CentreViewData: CentreViewDataProvider, Hashable, Identifiable {
    public let id: String
    let dayText: String?
    let timeText: String?
    let addressNameText: String?
    let addressText: String?
    let phoneText: String?
    let bookingButtonText: String
    let vaccineTypesTexts: AccessibilityString
    let centerTypeText: String?
    let appointmentsCount: Int?
    let isAvailable: Bool
    let partnerLogo: UIImage?
    let partnerName: String?
    let notificationsType: FollowedCentre.NotificationsType?
}

// MARK: - Centre Cell

final class CentreCell: UITableViewCell {

    @IBOutlet weak private var dateContainer: UIStackView!
    @IBOutlet weak private var dateLabel: UILabel!

    @IBOutlet weak private(set) var addressNameContainer: UIStackView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var addressLabel: UILabel!

    @IBOutlet weak private var phoneNumberContainer: UIStackView!
    @IBOutlet weak private var phoneButton: UIButton!

    @IBOutlet weak private var vaccineTypesContainer: UIStackView!
    @IBOutlet weak private var vaccineTypesLabel: UILabel!

    @IBOutlet weak private var centerTypeContainer: UIStackView!
    @IBOutlet weak private var centerTypeLabel: UILabel!

    @IBOutlet weak private var appointmentsLabel: UILabel!

    @IBOutlet weak private var bookingButton: UIButton!
    @IBOutlet weak private var cellContentView: UIView!

    @IBOutlet weak private var vaccineTypeImageView: UIImageView!

    @IBOutlet weak private(set) var followCentreButton: UIButton!

    var addressTapHandler: (() -> Void)?
    var phoneNumberTapHandler: (() -> Void)?
    var bookingButtonTapHandler: (() -> Void)?
    var followButtonTapHandler: (() -> Void)?

    private enum Constant {
        static let cellContentViewCornerRadius: CGFloat = 15
        static let bookingButtonCornerRadius: CGFloat = 8

        static let dateFont: UIFont = .accessibleSubheadMedium
        static let dateHighlightedFont: UIFont = .accessibleBodyHeavy
        static let labelPrimaryFont: UIFont = .accessibleCalloutMedium
        static let labelPrimaryColor: UIColor = .label
        static let labelSecondaryColor: UIColor = .secondaryLabel
        static let appointmentsLabelFont: UIFont = .accessibleSubheadMedium
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
        configureFollowCentreButton(viewData)
        configureAccessibility(viewData)

        let dateText = createDateText(
            dayText: viewData.dayText,
            timeText: viewData.timeText,
            isAvailable: viewData.isAvailable
        )
        dateLabel.attributedText = dateText
        dateLabel.adjustsFontForContentSizeCategory = false

        nameLabel.text = viewData.addressNameText
        nameLabel.font = Constant.labelPrimaryFont
        nameLabel.textColor = Constant.labelPrimaryColor
        nameLabel.adjustsFontForContentSizeCategory = true

        addressLabel.text = viewData.addressText
        addressLabel.textColor = Constant.labelSecondaryColor
        addressLabel.font = .accessibleSubheadRegular
        addressLabel.adjustsFontForContentSizeCategory = true

        let addressTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapAddress)
        )
        addressNameContainer.addGestureRecognizer(addressTapGesture)

        vaccineTypesContainer.isHidden = viewData.vaccineTypesTexts.rawValue.isEmpty
        vaccineTypesLabel.text = viewData.vaccineTypesTexts.rawValue
        vaccineTypesLabel.font = Constant.labelPrimaryFont
        vaccineTypesLabel.textColor = Constant.labelPrimaryColor

        centerTypeContainer.isHidden = viewData.centerTypeText == nil
        centerTypeLabel.text = viewData.centerTypeText
        centerTypeLabel.font = Constant.labelPrimaryFont
        centerTypeLabel.textColor = Constant.labelPrimaryColor
        centerTypeLabel.numberOfLines = .zero

        configureAppointmentsLabel(appointmentsCount: viewData.appointmentsCount, partnerLogo: viewData.partnerLogo, partnerName: viewData.partnerName)
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
        partnerLogo: UIImage?,
        partnerName: String?
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
        appointmentsLabel.isAccessibilityElement = true
        appointmentsLabel.accessibilityLabel = appointmentsText + Localization.A11y.VoiceOver.Details.to_use_with_platform + String.space  + partnerName.emptyIfNil
        appointmentsLabel.adjustsFontForContentSizeCategory = true
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
        phoneButton.accessibilityLabel = Localization.A11y.VoiceOver.Details.call + String.space + phoneButtonAttributedText.string
        phoneButton.accessibilityHint = Localization.A11y.VoiceOver.Actions.call_button
    }

    private func configureBookButton(_ viewData: CentreViewData) {
        let imageAttachment = NSTextAttachment()
        let iconImage = UIImage(
            systemName: "arrow.up.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        )
        iconImage?.isAccessibilityElement = false
        imageAttachment.image = iconImage?.withTintColor(.white, renderingMode: .alwaysOriginal)

        let bookingButtonAttributedText = NSMutableAttributedString(
            string: viewData.bookingButtonText,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ]
        )

        bookingButtonAttributedText.append(NSAttributedString(attachment: imageAttachment))

        let availableButtonColor: UIColor = .royalBlue
        bookingButton.backgroundColor = viewData.isAvailable ? availableButtonColor : .darkGray
        bookingButton.setTitleColor(.white, for: .normal)
        bookingButton.setAttributedTitle(bookingButtonAttributedText, for: .normal)
        bookingButton.addTarget(
            self,
            action: #selector(didTapBookButton),
            for: .touchUpInside
        )
        bookingButton.accessibilityLabel = viewData.bookingButtonText
        bookingButton.accessibilityHint = Localization.A11y.VoiceOver.Actions.booking_button
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

    private func configureAccessibility(_ viewData: CentreViewData) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if
            let dayText = viewData.dayText,
            let timeText = viewData.timeText,
            let dayDate = dateFormatter.date(from: timeText)
        {
            let hourComponents = Calendar.current.dateComponents([.hour, .minute], from: dayDate)
            if let localizedHours = DateComponentsFormatter.localizedString(from: hourComponents, unitsStyle: .spellOut) {
                dateLabel.accessibilityLabel = dayText + String.space + Localization.A11y.VoiceOver.Details.from + localizedHours
            } else {
                dateLabel.accessibilityLabel = dayText
            }
        }

        if let vaccineName = viewData.vaccineTypesTexts.vocalizedValue {
            vaccineTypesLabel.accessibilityLabel = Localization.A11y.VoiceOver.Details.vaccine.format(vaccineName)
        }

        accessibilityElements = [
            dateLabel,
            nameLabel,
            addressLabel,
            phoneButton,
            vaccineTypesLabel,
            centerTypeLabel,
            followCentreButton,
            bookingButton,
            appointmentsLabel
        ].compacted
    }

    private func setCornerRadius(to radius: CGFloat, for views: [UIView]) {
        views.forEach { $0.setCornerRadius(radius) }
    }

    private func resetTextFor(_ labels: [UILabel]) {
        labels.forEach { $0.text = nil }
    }
}
