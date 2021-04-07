//
//  HomeHeaderView.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

protocol HomeHeaderViewDelegate: class {
	func didSelect(_ county: County?)
}

class HomeHeaderView: UIView {
	@IBOutlet private var countiesPickerView: UIPickerView!
	private(set) var counties: Counties?
	weak var delegate: HomeHeaderViewDelegate?

	func configure(with viewData: ViewData) {
		countiesPickerView.dataSource = self
		countiesPickerView.delegate = self

		counties = viewData.counties
		countiesPickerView.reloadAllComponents()
	}
}

extension HomeHeaderView: UIPickerViewDataSource {
	struct ViewData {
		let counties: Counties
	}
}

extension HomeHeaderView {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		counties?.count ?? 0
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		counties?[safe: row]?.nomDepartement ?? ""
	}
}

extension HomeHeaderView: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		delegate?.didSelect(counties?[safe: row])
	}
}
