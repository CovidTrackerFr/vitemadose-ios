//
//  CreditSectionView.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import UIKit

protocol CreditSectionViewDataProvider {
    var title: String { get }
}

struct CreditSectionViewData: CreditSectionViewDataProvider, Hashable {
    var title: String
}

class CreditSectionView: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    
    private enum Constant {
        static let creditNameTextColor: UIColor = .label
        static let labelsFont: UIFont = .rounded(ofSize: 18, weight: .bold)
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewData: CreditSectionViewDataProvider) {
        contentView.backgroundColor = .athensGray

        titleLabel.text = viewData.title

        titleLabel.textColor = Constant.creditNameTextColor

        titleLabel.font = Constant.labelsFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
