//
//  CentreDataDisclaimerCell.swift
//  ViteMaDose
//
//  Created by Corentin Medina on 18/05/2021.
//

import UIKit

protocol CentreDataDisclaimerCellViewDataProvider {
    var contentText: String { get }
}

public struct CentreDataDisclaimerCellViewData: CentreDataDisclaimerCellViewDataProvider, Hashable {
    let contentText: String
}

final class CentreDataDisclaimerCell: UITableViewCell {
    @IBOutlet weak var infoIconImageView: UIImageView!
    @IBOutlet var contentTextTitleLabel: UILabel!
    @IBOutlet weak var disclaimerView: UIView!

    private enum Constant {
        static let disclaimerTextFont: UIFont = .rounded(ofSize: 14, weight: .regular)
        static let disclaimerTextColor: UIColor = .horsesNeck
        static let detailViewsCornerRadius: CGFloat = 15
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        contentView.backgroundColor = .athensGray
        selectionStyle = .none
    }

    func configure(with viewData: CentreDataDisclaimerCellViewDataProvider) {
        contentTextTitleLabel.text = viewData.contentText
        configureView()
    }

    func configureView() {
        infoIconImageView.image = UIImage(systemName: "info.circle.fill")?.tint(with: .horsesNeck)
        contentTextTitleLabel.font = Constant.disclaimerTextFont
        contentTextTitleLabel.textColor = Constant.disclaimerTextColor
        disclaimerView.setCornerRadius(Constant.detailViewsCornerRadius)
        disclaimerView.backgroundColor = .creamBrulee
    }
}
