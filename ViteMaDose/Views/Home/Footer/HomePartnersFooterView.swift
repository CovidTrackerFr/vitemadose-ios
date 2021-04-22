//
//  HomePartnersTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 11/04/2021.
//

import UIKit

class HomePartnersFooterView: UIView {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var logo1ImageView: UIImageView!
    @IBOutlet private var logo2ImageView: UIImageView!
    @IBOutlet private var logo3ImageView: UIImageView!
    @IBOutlet private var logo4ImageView: UIImageView!
    @IBOutlet var logoImageView5: UIImageView!

    private lazy var allLogos: [UIImageView] = [
        logo1ImageView,
        logo2ImageView,
        logo3ImageView,
        logo4ImageView,
        logoImageView5,
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        
        titleLabel.text = LocalizedString.find_appointment_with
        titleLabel.font = .systemFont(ofSize: 13, weight: .light)
        titleLabel.textColor = .secondaryLabel

        for logoImageView in allLogos {
            logoImageView.image = logoImageView.image?.tint(with: .systemGray)
        }
    }
}
