//
//  CreditViewController.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import UIKit
import Haptica

protocol CreditViewControllerDelegate: class {
    func didSelect(credit: Credit)
}

class CreditViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    weak var delegate: CreditViewControllerDelegate?

    var viewModel: CreditViewModel!

    private lazy var countySelectionHeaderView: CreditHeaderView = CreditHeaderView.instanceFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("ViewModel was not set for CreditViewController")
        }
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
        view.backgroundColor = .athensGray
        tableView.backgroundColor = .athensGray
        tableView.tableHeaderView = countySelectionHeaderView
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(cellType: CreditCell.self)
        tableView.register(cellType: CreditSectionView.self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.credit, screenClass: Self.className)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateHeaderViewHeight()
    }
}

// MARK: - UITableViewDataSource

extension CreditViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Case of title
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(with: CreditSectionView.self, for: indexPath)
            guard let cellViewModel = viewModel.sectionViewModel(at: indexPath.section) else {
                assertionFailure("Cell view model missing at \(indexPath)")
                return UITableViewCell()
            }
            
            cell.configure(with: cellViewModel)
            return cell
        }
        
        // Case of user
        let cell = tableView.dequeueReusableCell(with: CreditCell.self, for: indexPath)
        guard let cellViewModel = viewModel.cellViewModel(at: indexPath) else {
            assertionFailure("Cell view model missing at \(indexPath)")
            return UITableViewCell()
        }
        
        cell.configure(with: cellViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCell(at: indexPath)
        Haptic.impact(.light).generate()
    }
}

extension CreditViewController: CreditViewModelDelegate {
    func reloadTableView(with credits: Credits) {
        tableView.reloadData()
    }

    func dismissViewController(with credit: Credit) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelect(credit: credit)
        }
    }
}
