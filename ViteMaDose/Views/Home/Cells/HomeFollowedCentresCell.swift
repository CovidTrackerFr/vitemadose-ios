//
//  HomeFollowedCentresCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/05/2021.
//

import Foundation
import UIKit

final class HomeFollowedCentresCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var cellContainerView: UIView!
    @IBOutlet private var iconContainerView: UIView!

    private enum Constant {
        static let codeTextColor: UIColor = .white
        static let nameTextColor: UIColor = .label
        static let codeBackgroundColor: UIColor = .royalBlue
        static let cellBackgroundColor: UIColor = .tertiarySystemBackground
        static let titleFont: UIFont = .accessibleTitle1Bold
        static let labelsFont: UIFont = .rounded(ofSize: 18, weight: .bold)
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure() {
        contentView.backgroundColor = .athensGray

        iconContainerView.backgroundColor = .mandy
        cellContainerView.backgroundColor = .tertiarySystemBackground

        iconContainerView.setCornerRadius(15)
        cellContainerView.setCornerRadius(15)

        titleLabel.text = "Mes centres suivis"
        titleLabel.textColor = .label
        titleLabel.font = Constant.titleFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
