//
//  CountySelectionViewController.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation
import UIKit
import Haptica

protocol CountySelectionViewControllerDelegate: AnyObject {
    func didSelect(county: County)
}

class CountySelectionViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    weak var delegate: CountySelectionViewControllerDelegate?

    var viewModel: CountySelectionViewModel!

    private lazy var countySelectionHeaderView: CountySelectionHeaderView = CountySelectionHeaderView.instanceFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("ViewModel was not set for CountySelectionViewController")
        }
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
        view.backgroundColor = .athensGray
        tableView.backgroundColor = .athensGray
        tableView.tableHeaderView = countySelectionHeaderView
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(cellType: CountyCell.self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.departmentSelect, screenClass: Self.className)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateHeaderViewHeight()
    }
}

// MARK: - UITableViewDataSource

extension CountySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CountyCell.self, for: indexPath)
        guard let cellViewModel = viewModel.cellViewModel(at: indexPath) else {
            assertionFailure("Cell view model missing at \(indexPath)")
            return UITableViewCell()
        }

        cell.configure(with: cellViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CountySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCell(at: indexPath)
        Haptic.impact(.light).generate()
    }
}

extension CountySelectionViewController: CountySelectionViewModelDelegate {
    func reloadTableView(with counties: Counties) {
        tableView.reloadData()
    }

    func dismissViewController(with county: County) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelect(county: county)
        }
    }
}
