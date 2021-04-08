//
//  HomeHeaderView.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

protocol HomeHeaderViewDelegate: class {
	func didSelect()
}

class HomeHeaderView: UIView {
	@IBOutlet private var searchBar: UISearchBar!
    weak var delegate: HomeHeaderViewDelegate?

    func configure() {
        // Needed to get rid of the 1px solid grey lines around the search bar
        // See https://stackoverflow.com/questions/7620564/customize-uisearchbar-trying-to-get-rid-of-the-1px-black-line-underneath-the-se
        searchBar.backgroundImage = UIImage.init()
    }

    func countySelected(_ county: County) {
        searchBar.text = "\(county.nomDepartement ?? "") (\(county.codeDepartement ?? ""))"
    }
}

extension HomeHeaderView: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        delegate?.didSelect()
        return false;
    }
}
