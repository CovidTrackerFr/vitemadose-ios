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
    case externalMap
}

protocol HomeStatsCellViewDataProvider: HomeCellViewDataProvider {
    var title: NSMutableAttributedString { get }
    var description: String? { get }
    var icon: UIImage? { get }
    var iconContainerColor: UIColor { get }
    var dataType: StatsDataType { get }
}

class HomeStatsCell: UITableViewCell {
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

    var title: NSMutableAttributedString
    var description: String?
    var icon: UIImage?
    var iconContainerColor: UIColor
    var dataType: StatsDataType

    init(_ dataType: StatsDataType) {
        self.dataType = dataType
        icon = dataType.iconImage

        switch dataType {
            case let .allCentres(count):
                title = NSMutableAttributedString(string: String(count))
                description = "Centres trouvés en France"
                iconContainerColor = .systemOrange
            case let .centresWithAvailabilities(count):
                title = NSMutableAttributedString(string: String(count))
                description = "Centres avec rendez-vous disponibles"
                iconContainerColor = .systemGreen
            case let .allAvailabilities(count):
                title = NSMutableAttributedString(string: String(count))
                description = "Créneaux disponibles"
                iconContainerColor = .systemBlue
            case .externalMap:
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(
                    systemName: "arrow.up.right",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
                )?.withTintColor(.label, renderingMode: .alwaysOriginal)

                let fullString = NSMutableAttributedString(string: "Ouvrir la carte des centres ")
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
            case .externalMap:
                imageName = "mappin"
        }

        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        return image?.withTintColor(.white, renderingMode: .alwaysOriginal)
    }

}
