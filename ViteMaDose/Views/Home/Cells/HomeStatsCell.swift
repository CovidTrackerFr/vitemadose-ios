//
//  HomeStatsCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 10/04/2021.
//

import UIKit

enum StatsDataType: Hashable {
    case allCentres(Int)
    case centresWithAvailabilities(Int)
    case allAvailabilities(Int)
    case percentageAvailabilities(Double?)
    case externalMap
}

protocol HomeStatsCellViewDataProvider {
    var title: NSMutableAttributedString { get }
    var description: String? { get }
    var icon: UIImage? { get }
    var iconContainerColor: UIColor { get }
    var dataType: StatsDataType { get }
}

final class HomeStatsCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet var iconContainerView: UIView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet var cellContentView: UIView!

    private enum Constant {
        static let titleFont = UIFont.rounded(ofSize: 26, weight: .bold)
        static let titleColor = UIColor.label
        static let descriptionFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        static let descriptionColor = UIColor.secondaryLabel
        static let searchBarViewCornerRadius: CGFloat = 15
    }

    func configure(with viewData: HomeStatsCellViewDataProvider) {
        contentView.backgroundColor = .athensGray

        titleLabel.attributedText = viewData.title
        titleLabel.textColor = Constant.titleColor
        titleLabel.font = Constant.titleFont

        // Some values returned by backend are not vocalized as numbers, like "226 095".
        // In this case we need to remove white spaces from text value, try to cast to Int and define the label
        if let integerTitleValue = Int(viewData.title.string.replacingOccurrences(of: " ", with: "")) {
            titleLabel.accessibilityLabel = NumberFormatter.localizedString(from: NSNumber(value: integerTitleValue), number: .spellOut)
        }

        if case .externalMap = viewData.dataType {
            accessibilityLabel = viewData.title.string
            accessibilityTraits = .button
            accessibilityHint = Localization.A11y.VoiceOver.HomeScreen.display_places_on_map
        }

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

struct HomeCellStatsViewData: HomeStatsCellViewDataProvider, Hashable {
    let title: NSMutableAttributedString
    let description: String?
    let icon: UIImage?
    let iconContainerColor: UIColor
    let dataType: StatsDataType

    init(_ dataType: StatsDataType) {
        self.dataType = dataType
        icon = dataType.iconImage

        switch dataType {
        case let .allCentres(count):
            title = NSMutableAttributedString(string: count.formattedWithSeparator)
            description = Localization.Home.Stats.all_locations
            iconContainerColor = .systemOrange
        case let .centresWithAvailabilities(count):
            title = NSMutableAttributedString(string: count.formattedWithSeparator)
            description = Localization.Home.Stats.locations_with_availabilities
            iconContainerColor = .systemGreen
        case let .allAvailabilities(count):
            title = NSMutableAttributedString(string: count.formattedWithSeparator)
            description = Localization.Home.Stats.all_availabilities
            iconContainerColor = .royalBlue
        case let .percentageAvailabilities(count):
            let formattedCount = count?.formattedWithPercentage ?? "-"
            title = NSMutableAttributedString(string: formattedCount)
            description = Localization.Home.Stats.available_locations_percentage
            iconContainerColor = .systemBlue
        case .externalMap:
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(
                systemName: "arrow.up.right",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            )?.withTintColor(.label, renderingMode: .alwaysOriginal)

            let fullString = NSMutableAttributedString(string: Localization.Home.open_map + String.space)
            fullString.append(NSAttributedString(attachment: imageAttachment))
            title = fullString
            description = nil
            iconContainerColor = .systemRed
        }
    }
}

private extension StatsDataType {

    var iconImage: UIImage? {
        let imageName: String
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)

        switch self {
        case .allCentres:
            imageName = "magnifyingglass"
        case .centresWithAvailabilities:
            imageName = "checkmark"
        case .allAvailabilities:
            imageName = "calendar"
        case .percentageAvailabilities:
            imageName = "percent"
        case .externalMap:
            imageName = "mappin"
        }

        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        return image?.withTintColor(.white, renderingMode: .alwaysOriginal)
    }
}
