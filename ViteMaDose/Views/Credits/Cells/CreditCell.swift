//
//  CreditCell.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import UIKit
import Kingfisher

protocol CreditCellViewDataProvider {
    var creditName: String { get }
    var creditRole: String { get }
    var creditLink: URL? { get }
    var creditImage: String? { get }
}

struct CreditCellViewData: CreditCellViewDataProvider, Hashable {
    var creditName: String
    var creditRole: String
    var creditLink: URL?
    var creditImage: String?
}

class CreditCell: UITableViewCell {
    @IBOutlet private var creditImageView: UIImageView!
    @IBOutlet private var creditNameLabel: UILabel!
    @IBOutlet private var creditRoleLabel: UILabel!
    @IBOutlet private var creditLinkButton: UIButton!
    @IBOutlet private var creditContainerView: UIView!
    
    private var buttonURL: URL?
    private weak var delegate: CreditViewModelDelegate?

    @IBAction func creditLinkButtonClicked(_ sender: Any) {
        if let buttonURL = buttonURL {
            delegate?.openURL(url: buttonURL)
        }
    }
    
    private enum Constant {
        static let creditNameTextColor: UIColor = .label
        static let creditImageBackgroundColor: UIColor = .royalBlue
        static let cellBackgrounColor: UIColor = .tertiarySystemBackground
        static let labelMainFont: UIFont = .accessibleCalloutBold
        static let labelSecondFont: UIFont = .accessibleSubheadMedium
        static let buttonColor: UIColor = .royalBlue
        static let viewsCornerRadius: CGFloat = 15
    }

    func configure(with viewData: CreditCellViewDataProvider, delegate: CreditViewModelDelegate?) {
        self.buttonURL = viewData.creditLink
        self.delegate = delegate
        
        contentView.backgroundColor = .athensGray

        creditImageView.backgroundColor = Constant.creditImageBackgroundColor
        creditContainerView.backgroundColor = Constant.cellBackgrounColor

        creditImageView.setCornerRadius(Constant.viewsCornerRadius)
        creditContainerView.setCornerRadius(Constant.viewsCornerRadius)

        creditImageView.kf.setImage(with: URL(string: viewData.creditImage ?? ""))
        creditNameLabel.text = viewData.creditName
        creditRoleLabel.text = viewData.creditRole
        creditLinkButton.isHidden = buttonURL == nil

        creditNameLabel.textColor = Constant.creditNameTextColor
        creditRoleLabel.textColor = Constant.creditNameTextColor
        creditLinkButton.tintColor = Constant.buttonColor

        creditNameLabel.font = Constant.labelMainFont
        creditRoleLabel.font = Constant.labelSecondFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        creditNameLabel.text = nil
        creditImageView.kf.cancelDownloadTask()
        creditImageView.image = nil
    }
}
