//
//  HomeHeaderView.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

protocol HomeHeaderViewDelegate: class {
    func didTapSearchBarView(_ searchBarView: UIView)
}

class HomeHeaderView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var searchBarView: UIView!
    @IBOutlet private var searchBarTitle: UILabel!
    @IBOutlet private var statsTitle: UILabel!

    weak var delegate: HomeHeaderViewDelegate?

    private enum Constant {
        static let titleFont = UIFont.rounded(ofSize: 26, weight: .bold)
        static let searchBarFont = UIFont.rounded(ofSize: 16, weight: .medium)
        static let searchBarViewCornerRadius: CGFloat = 10.0
    }

    private lazy var searchBarTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(didTapSearchBarView)
    )

    private lazy var viewData = ViewData(
        titleText: "Trouvez une dose de vaccin facilement et rapidement",
        titleFirstHighlightedText: "facilement",
        titleSecondHighlightedText: "rapidement",
        titleFirstHighlightedTextColor: .royalBlue,
        titleSecondHighlightedTextColor: .mandy,
        searchBarText: "Séléctionner un département..."
    )

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .athensGray
        configureTitle()
        configureSearchBarView()
    }

    private func configureTitle() {
        let attributedText = NSMutableAttributedString(
            string: viewData.titleText,
            attributes: [
                NSAttributedString.Key.font: Constant.titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ]
        )
        attributedText.setColorForText(
            textForAttribute: viewData.titleFirstHighlightedText,
            withColor: viewData.titleFirstHighlightedTextColor
        )
        attributedText.setColorForText(
            textForAttribute: viewData.titleSecondHighlightedText,
            withColor: viewData.titleSecondHighlightedTextColor
        )

        titleLabel.attributedText = attributedText
        statsTitle.font = Constant.titleFont
        statsTitle.textColor = .label
    }

    private func configureSearchBarView() {
        searchBarView.addGestureRecognizer(searchBarTapGesture)
        searchBarTitle.text = viewData.searchBarText
        searchBarTitle.font = Constant.searchBarFont
        searchBarView.backgroundColor = .tertiarySystemBackground
        let shadow = UIView.Shadow(
            color: .label,
            opacity: 0.05,
            offset: CGSize(width: 0, height: 5),
            radius: 5
        )
        searchBarView.setCornerRadius(15, withShadow: shadow)
    }

    @objc func didTapSearchBarView() -> Bool {
        delegate?.didTapSearchBarView(searchBarView)
        return false
    }
}

extension HomeHeaderView {
    struct ViewData {
        let titleText: String
        let titleFirstHighlightedText: String
        let titleSecondHighlightedText: String
        let titleFirstHighlightedTextColor: UIColor
        let titleSecondHighlightedTextColor: UIColor
        let searchBarText: String
    }
}
