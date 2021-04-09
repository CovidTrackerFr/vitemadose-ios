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
    weak var delegate: HomeHeaderViewDelegate?

    private enum Constant {
        static let titleFont = UIFont.systemFont(ofSize: 34, weight: .bold)
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
        backgroundColor = .wildSand
        configureTitle()
        configureSearchBarView()
    }

    private func configureTitle() {
        let font: UIFont
        if let descriptor = Constant.titleFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: Constant.titleFont.pointSize)
        } else {
            font = Constant.titleFont
        }

        let attributedText = NSMutableAttributedString(
            string: viewData.titleText,
            attributes: [
                NSAttributedString.Key.font: font,
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
    }

    private func configureSearchBarView() {
        searchBarView.addGestureRecognizer(searchBarTapGesture)
        searchBarTitle.text = viewData.searchBarText
        searchBarView.backgroundColor = .white
        searchBarView.layer.cornerRadius = Constant.searchBarViewCornerRadius
        searchBarView.dropShadow(
            color: .black,
            opacity: 0.15,
            offSet: CGSize(width: 0, height: 0),
            radius: 10.0,
            scale: true
        )
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
