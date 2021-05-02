//
//  DepartmentSelectionViewController.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation
import UIKit
import Haptica

protocol DepartmentSelectionViewControllerDelegate: AnyObject {
    func didSelect(department: Department)
}

class DepartmentSelectionViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    weak var delegate: DepartmentSelectionViewControllerDelegate?

    var viewModel: DepartmentSelectionViewModel!

    private lazy var departmentSelectionHeaderView: DepartmentSelectionHeaderView = DepartmentSelectionHeaderView.instanceFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("ViewModel was not set for DepartmentSelectionViewController")
        }
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
        view.backgroundColor = .athensGray
        tableView.backgroundColor = .athensGray
        tableView.tableHeaderView = departmentSelectionHeaderView
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(cellType: DepartmentCell.self)
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

extension DepartmentSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: DepartmentCell.self, for: indexPath)
        guard let cellViewModel = viewModel.cellViewModel(at: indexPath) else {
            assertionFailure("Cell view model missing at \(indexPath)")
            return UITableViewCell()
        }

        cell.configure(with: cellViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DepartmentSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCell(at: indexPath)
        Haptic.impact(.light).generate()
    }
}

extension DepartmentSelectionViewController: DepartmentSelectionViewModelDelegate {
    func reloadTableView(with departments: Departments) {
        tableView.reloadData()
    }

    func dismissViewController(with department: Department) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelect(department: department)
        }
    }
}
