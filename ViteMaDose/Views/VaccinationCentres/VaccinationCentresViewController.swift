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

    private typealias Snapshot = NSDiffableDataSourceSnapshot<VaccinationCentresSection, VaccinationCentresCell>

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

    private lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("VaccinationCentresViewController should have a ViewModel!")
        }

        configureTableView()
        configureNavigationBar()

        view.backgroundColor = .athensGray
        viewModel.delegate = self
        viewModel.load()
    }

    @objc private func didPullToRefresh() {
        viewModel.load()
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

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource

        tableView.backgroundColor = .athensGray
        tableView.contentInset.top = -10

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        tableView.refreshControl = refreshControl
        tableView.backgroundView = activityIndicator

        tableView.register(cellType: CentresTitleCell.self)
        tableView.register(cellType: CentreCell.self)
        tableView.register(cellType: CentresStatsCell.self)
    }
}

extension VaccinationCentresViewController: VaccinationCentresViewModelDelegate {
    func reloadTableView(with cells: [VaccinationCentresCell]) {
        var snapshot = Snapshot()
        snapshot.appendSections(VaccinationCentresSection.allCases)
        snapshot.appendItems(cells, toSection: .centres)

        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func reloadTableViewFooter(with text: String?) {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.text = text
        label.sizeToFit()

        tableView.tableFooterView = label
    }

    func updateLoadingState(isLoading: Bool, isEmpty: Bool) {
        tableView.tableFooterView?.isHidden = isLoading
        
        if !isLoading {
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
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
                self.navigationController?.popViewController(animated: true)
            },
            completionHandler: nil
        )
    }
}

extension VaccinationCentresViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Show details
    }
}

// MARK: - DataSource

extension VaccinationCentresViewController {

    private func makeDataSource() -> UITableViewDiffableDataSource<VaccinationCentresSection, VaccinationCentresCell> {
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, vaccinationCentreCell in
                return self?.dequeueAndConfigure(cell: vaccinationCentreCell, at: indexPath)
            }
        )
    }

    private func dequeueAndConfigure(cell: VaccinationCentresCell, at indexPath: IndexPath) -> UITableViewCell {
        switch cell {
            case let .title(cellViewData):
                let cell = tableView.dequeueReusableCell(with: CentresTitleCell.self, for: indexPath)
                cell.configure(with: cellViewData)
                return cell
            case let .stats(cellViewData):
                let cell = tableView.dequeueReusableCell(with: CentresStatsCell.self, for: indexPath)
                cell.configure(with: cellViewData)
                return cell
            case let .centre(cellViewData):
                let cell = tableView.dequeueReusableCell(with: CentreCell.self, for: indexPath)
                cell.bookingButtonTapHandler = { [weak self] in
                    guard let bookingURL = self?.viewModel.bookingLink(at: indexPath) else {
                        return
                    }
                    self?.openBookingUrl(bookingURL)
                }
                cell.configure(with: cellViewData)
                return cell
        }
    }
}


extension VaccinationCentresViewController: UIGestureRecognizerDelegate {
    /// Enable swipe to go back
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
