//
//  VaccinationCentresViewController.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import UIKit
import SafariServices

class VaccinationCentresViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    var viewModel: VaccinationCentresViewModel!

    private lazy var vaccinationCentresHeaderView: VaccinationCentresHeaderView = {
        let view: VaccinationCentresHeaderView = VaccinationCentresHeaderView.instanceFromNib()
        view.isHidden = true
        return view
    }()

    private lazy var footerView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("VaccinationCentresViewController should have a ViewModel!")
        }

        configureTableView()
        configureNavigationBar()

        view.backgroundColor = .athensGray
        viewModel.delegate = self
        viewModel.fetchVaccinationCentres()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateHeaderViewHeight()
    }

    @objc private func didPullToRefresh() {
        viewModel.fetchVaccinationCentres()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func openBookingUrl(_ url: URL) {
        let config = SFSafariViewController.Configuration()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        present(safariViewController, animated: true)
    }

    private func configureNavigationBar() {
        let backButtonImageConfiguration = UIImage.SymbolConfiguration.init(
            pointSize: 24,
            weight: .semibold,
            scale: .medium
        )
        let backButtonImage = UIImage(
            systemName: "arrow.left",
            withConfiguration: backButtonImageConfiguration
        )?.withTintColor(.label, renderingMode: .alwaysOriginal)

        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let backBarButtonItem = UIBarButtonItem(customView: backButton)

        navigationItem.setLeftBarButton(backBarButtonItem, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .athensGray
        tableView.contentInset.top = -10

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = vaccinationCentresHeaderView
        tableView.tableFooterView = footerView

        tableView.refreshControl = refreshControl
        tableView.backgroundView = activityIndicator

        tableView.register(cellType: VaccinationBookingTableViewCell.self)
    }
}

extension VaccinationCentresViewController: VaccinationCentresViewModelDelegate {
    func reloadTableViewHeader(with viewModel: VaccinationCentresHeaderViewModelProvider) {
        vaccinationCentresHeaderView.configure(with: viewModel)
        vaccinationCentresHeaderView.isHidden = false
        tableView.updateHeaderViewHeight()
    }

    func reloadTableView(isEmpty: Bool) {
        tableView.reloadData()
    }

    func reloadTableViewFooter(with text: String?) {
        footerView.text = text
        footerView.sizeToFit()
    }

    func updateLoadingState(isLoading: Bool) {
        if !isLoading {
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }

    func displayError(withMessage message: String) {
        // TODO: Error Popup
    }
}

extension VaccinationCentresViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            with: VaccinationBookingTableViewCell.self,
            for: indexPath
        )
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cell.bookingButtonTapHandler = { [weak self] in
            guard let bookingURL = self?.viewModel.bookingLink(at: indexPath) else {
                return
            }
            self?.openBookingUrl(bookingURL)
        }
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension VaccinationCentresViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Show details
    }
}

extension VaccinationCentresViewController {

}
