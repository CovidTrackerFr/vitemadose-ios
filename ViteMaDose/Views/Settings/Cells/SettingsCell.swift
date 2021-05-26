// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GPL-3.0
//
// This software is distributed under the GNU General Public License v3.0 only.
//
// Author: Pierre-Yves LAPERSONNE <dev(at)pylapersonne(dot)info> et al.

import UIKit

// MARK: - Settings Data Type

/// Types of cells to display in the settings screen
enum SettingsDataType: Hashable {
    case header
    /// Cell dedicated to the project website
    case website
    /// Cell dedicated to contact the team
    case contact
    /// Cell dedicated to the Twitter profile
    case twitter
    /// Cell dedicated to the GitHub repository
    case appSourceCode
    /// Celle which redirects to the systems ettings to get details
    case systemSettings
    // TODO: Cell for contributors
}

private extension SettingsDataType {

    var iconImage: UIImage? {
        let imageName: String?
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)

        switch self {
        case .header:
            imageName = nil
        case .website:
            imageName = "safari.fill"
        case .contact:
            imageName = "message.fill"
        case .twitter:
            imageName = "pencil"
        case .appSourceCode:
            imageName = "cursorarrow.square"
        case .systemSettings:
            imageName = "wrench.and.screwdriver.fill"
        }

        if let imageName = imageName, let image = UIImage(systemName: imageName, withConfiguration: configuration) {
            return image.withTintColor(.white, renderingMode: .alwaysOriginal)
        } else {
            return nil
        }
    }
}

// MARK: - Settings Cell View Data Provider

protocol SettingsCellViewDataProvider {
    var title: NSMutableAttributedString { get }
    var description: String? { get }
    var icon: UIImage? { get }
    var iconContainerColor: UIColor { get }
    var dataType: SettingsDataType { get }
    var voiceOverHint: String? { get }
}

// MARK: - Settings Cell View Data

struct SettingsCellViewData: SettingsCellViewDataProvider, Hashable {

    let title: NSMutableAttributedString
    let description: String?
    let icon: UIImage?
    let iconContainerColor: UIColor
    let dataType: SettingsDataType
    let voiceOverHint: String?

    init?(_ dataType: SettingsDataType) {
        self.dataType = dataType
        icon = dataType.iconImage

        switch dataType {
        case .website:
            title = NSMutableAttributedString(string: Localization.Settings.WebSite.title)
            description = Localization.Settings.WebSite.subtitle
            iconContainerColor = .systemOrange
            voiceOverHint = Localization.A11y.VoiceOver.Settings.action_website
        case .contact:
            title = NSMutableAttributedString(string: Localization.Settings.Contact.title)
            description = Localization.Settings.Contact.subtitle
            iconContainerColor = .systemGreen
            voiceOverHint = Localization.A11y.VoiceOver.Settings.action_contact
        case .twitter:
            title = NSMutableAttributedString(string: Localization.Settings.Twitter.title)
            description = Localization.Settings.Twitter.subtitle
            iconContainerColor = .royalBlue
            voiceOverHint = Localization.A11y.VoiceOver.Settings.action_twitter
        case .appSourceCode:
            title = NSMutableAttributedString(string: Localization.Settings.SourceCode.title)
            description = Localization.Settings.SourceCode.subtitle
            iconContainerColor = .systemBlue
            voiceOverHint = Localization.A11y.VoiceOver.Settings.action_sourcecode
        case .systemSettings:
            title = NSMutableAttributedString(string: Localization.Settings.System.title)
            description = Localization.Settings.System.subtitle
            iconContainerColor = .systemRed
            voiceOverHint = Localization.A11y.VoiceOver.Settings.action_advanced
        default:
            return nil
        }
    }
}

// MARK: Settings Cell

final class SettingsCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var iconContainerView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var cellContentView: UIView!

    private enum Constant {
        static let titleFont = UIFont.rounded(ofSize: 26, weight: .bold) // FIXME: A11Y
        static let titleColor = UIColor.label
        static let descriptionFont = UIFont.systemFont(ofSize: 16, weight: .bold) // FIXME: A11Y
        static let descriptionColor = UIColor.secondaryLabel
        static let searchBarViewCornerRadius: CGFloat = 15
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(with viewData: SettingsCellViewDataProvider) {
        contentView.backgroundColor = .athensGray

        titleLabel.attributedText = viewData.title
        titleLabel.textColor = Constant.titleColor
        titleLabel.font = Constant.titleFont

        descriptionLabel.text = viewData.description
        descriptionLabel.textColor = Constant.descriptionColor
        descriptionLabel.font = Constant.descriptionFont
        descriptionLabel.isHidden = viewData.description == nil

        iconContainerView.setCornerRadius(iconContainerView.bounds.width / 2)
        iconImageView.image = viewData.icon
        iconContainerView.backgroundColor = viewData.iconContainerColor
        cellContentView.setCornerRadius(Constant.searchBarViewCornerRadius)
        cellContentView.backgroundColor = .tertiarySystemBackground
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        descriptionLabel.text = nil
        iconImageView.image = nil
    }
}
