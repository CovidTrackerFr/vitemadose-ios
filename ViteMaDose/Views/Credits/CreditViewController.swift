//
//  CreditViewController.swift
//  ViteMaDose
//
//  Created by Nathan FALLET on 20/04/2021.
//

import UIKit
import Haptica

protocol CreditViewControllerDelegate: AnyObject {
    func didSelect(credit: Credit)
}

class CreditViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    weak var delegate: CreditViewControllerDelegate?

    var viewModel: CreditViewModel!

    private lazy var countySelectionHeaderView: CreditHeaderView = CreditHeaderView.instanceFromNib()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("ViewModel was not set for CreditViewController")
        }

        configureTableView()

        view.backgroundColor = .athensGray
        viewModel.delegate = self
        viewModel.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.credit, screenClass: Self.className)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateHeaderViewHeight()
    }

    private func configureTableView() {
        tableView.dataSource = self

        tableView.backgroundColor = .athensGray
        tableView.tableHeaderView = countySelectionHeaderView
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundView = activityIndicator

        tableView.register(cellType: CreditCell.self)
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
        let cell = tableView.dequeueReusableCell(with: CreditCell.self, for: indexPath)
        guard let cellViewModel = viewModel.cellViewModel(at: indexPath) else {
            assertionFailure("Cell view model missing at \(indexPath)")
            return UITableViewCell()
        }

        cell.configure(with: cellViewModel, delegate: self)
        return cell
    }
}

// MARK: - CreditViewModelDelegate

extension CreditViewController: CreditViewModelDelegate {
    func reloadTableView(with credits: [Credit]) {
        tableView.reloadData()
    }

    func openURL(url: URL) {
        UIApplication.shared.open(url)
    }

    func updateLoadingState(isLoading: Bool, isEmpty: Bool) {
        if !isLoading {
            activityIndicator.stopAnimating()
        } else {
            guard isEmpty else { return }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }

    func presentLoadError(_ error: Error) {
        presentRetryableAndCancellableError(
            error: error,
            retryHandler: { [unowned self] _ in
                self.viewModel.load()
            },
            cancelHandler: { [unowned self] _ in
                self.dismiss(animated: true, completion: nil)
            },
            completionHandler: nil
        )
    }
}
