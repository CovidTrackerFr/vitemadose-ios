//
//  HomeStatsTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 10/04/2021.
//

import UIKit

enum StatsDataType {
    case allCentres(Int)
    case centresWithAvailabilities(Int)
    case allAvailabilities(Int)
    case externalMap
}

protocol HomeCellStatsViewModelProvider: HomeCellViewModelProvider {
    var viewData: HomeStatsTableViewCell.ViewData? { get }
}

struct HomeCellStatsViewModel: HomeCellStatsViewModelProvider {
    var cellType: HomeCellType = .stats
    var viewData: HomeStatsTableViewCell.ViewData?
}

class HomeStatsTableViewCell: UITableViewCell {
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
        static let iconConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
    }

    func configure(with viewModel: HomeCellStatsViewModelProvider?) {
        guard let viewModel = viewModel,
              case .stats = viewModel.cellType,
              let viewData = viewModel.viewData
        else {
            preconditionFailure("Invalid HomeCellStats view model")
        }
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

extension HomeStatsTableViewCell {
    struct ViewData {
        let title: NSMutableAttributedString
        let description: String?
        let icon: UIImage?
        let iconContainerColor: UIColor
        let dataType: StatsDataType

        init(_ dataType: StatsDataType) {
            self.dataType = dataType

            switch dataType {
                case let .allCentres(count):
                    title = NSMutableAttributedString(string: String(count))
                    description = "Centres trouvés en France"
                    icon = UIImage(
                        systemName: "magnifyingglass",
                        withConfiguration: Constant.iconConfiguration
                    )?.withTintColor(.white, renderingMode: .alwaysOriginal)
                    iconContainerColor = .systemOrange
                case let .centresWithAvailabilities(count):
                    title = NSMutableAttributedString(string: String(count))
                    description = "Centres avec rendez-vous disponibles"
                    icon = UIImage(
                        systemName: "checkmark",
                        withConfiguration: Constant.iconConfiguration
                    )?.withTintColor(.white, renderingMode: .alwaysOriginal)
                    iconContainerColor = .systemGreen
                case let .allAvailabilities(count):
                    title = NSMutableAttributedString(string: String(count))
                    description = "Créneaux disponibles"
                    icon = UIImage(
                        systemName: "calendar",
                        withConfiguration: Constant.iconConfiguration
                    )?.withTintColor(.white, renderingMode: .alwaysOriginal)
                    iconContainerColor = .systemBlue
                case .externalMap:
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = UIImage(
                        systemName: "arrow.up.right",
                        withConfiguration:UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
                    )?.withTintColor(.label, renderingMode: .alwaysOriginal)

                    let fullString = NSMutableAttributedString(string: "Ouvrir la carte des centres ")
                    fullString.append(NSAttributedString(attachment: imageAttachment))
                    title = fullString
                    description = nil
                    icon = UIImage(
                        systemName: "mappin",
                        withConfiguration: Constant.iconConfiguration
                    )?.withTintColor(.white, renderingMode: .alwaysOriginal)
                    iconContainerColor = .systemRed
            }
        }
    }
}
