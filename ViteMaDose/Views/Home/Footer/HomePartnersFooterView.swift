//
//  HomePartnersTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 11/04/2021.
//

import UIKit

final class HomePartnersFooterView: UIView {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var logo1ImageView: UIImageView!
    @IBOutlet private var logo2ImageView: UIImageView!
    @IBOutlet private var logo3ImageView: UIImageView!
    @IBOutlet private var logo4ImageView: UIImageView!
    @IBOutlet private var logoImageView5: UIImageView!
    @IBOutlet private var logo6ImageView: UIImageView!

    private lazy var allLogos: [UIImageView] = [
        logo1ImageView,
        logo2ImageView,
        logo3ImageView,
        logo4ImageView,
        logoImageView5,
        logo6ImageView
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray

        titleLabel.text = Localization.Home.partners
        titleLabel.font = UIFont.accessibleFootnoteLight
        titleLabel.textColor = .secondaryLabel
        titleLabel.isAccessibilityElement = false
        titleLabel.adjustsFontForContentSizeCategory = true

        for logoImageView in allLogos {
            logoImageView.image = logoImageView.image?.tint(with: .systemGray)
        }
    }
}
