//
//  VaccinationBookingTableViewCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 12/04/2021.
//

import UIKit

protocol VaccinationBookingCellViewModelProvider {
    var dateText: String? { get }
    var addressText: String? { get }
    var isAvailable: Bool { get }
    var url: URL? { get }
}

struct VaccinationBookingCellViewModel: VaccinationBookingCellViewModelProvider {
    var dateText: String?
    var addressText: String?
    var isAvailable: Bool
    var url: URL?
}

class VaccinationBookingTableViewCell: UITableViewCell {
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var bookingbutton: UIButton!
    @IBOutlet private var cellContentView: UIView!

    var bookingButtonTapHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .athensGray
        cellContentView.backgroundColor = .tertiarySystemBackground
        bookingbutton.backgroundColor = .royalBlue
        bookingbutton.setCornerRadius(8)
        cellContentView.setCornerRadius(15)
    }

    func configure(with viewModel: VaccinationBookingCellViewModelProvider?) {
        guard let viewModel = viewModel else {
            preconditionFailure("ViewModel is required")
        }
        dateLabel.text = viewModel.dateText
        addressLabel.text = viewModel.addressText
        bookingbutton.setTitle(viewModel.isAvailable ? "Prendre rendez vous" : "Verifier", for: .normal)
        bookingbutton.backgroundColor = viewModel.isAvailable ? .royalBlue : .systemGray
        bookingbutton.setTitleColor(.white, for: .normal)
        bookingbutton.addTarget(
            self,
            action: #selector(didTapBookButton),
            for: .touchUpInside
        )
    }

    @objc private func didTapBookButton() {
        bookingButtonTapHandler?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        addressLabel.text = nil
        bookingbutton.backgroundColor = nil
        bookingbutton.setTitle(nil, for: .normal)
    }
    
}
