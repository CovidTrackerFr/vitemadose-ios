//
//  HomeViewController.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit
import SafariServices
import FirebaseAnalytics
import Haptica

class HomeViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!

    private typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeCell>

    private lazy var viewModel: HomeViewModelProvider = {
        let viewModel = HomeViewModel()
        viewModel.delegate = self
        return viewModel
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private lazy var footerView: HomePartnersFooterView = {
        let view: HomePartnersFooterView = HomePartnersFooterView.instanceFromNib()
        view.isHidden = true
        return view
    }()

    private lazy var dataSource = makeDataSource()
    private let remoteConfiguration: RemoteConfiguration = .shared
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()

        remoteConfiguration.synchronize { [unowned self] _ in
            if let maintenanceUrlString = self.remoteConfiguration.maintenanceModeUrl {
                self.presentMaintenancePage(with: maintenanceUrlString)
                return
            }
            self.viewModel.load()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.home, screenClass: Self.className)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureViewController() {
        view.backgroundColor = .athensGray

        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundColor = .athensGray
        tableView.alwaysBounceVertical = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        tableView.refreshControl = refreshControl
        tableView.backgroundView = activityIndicator
        tableView.tableFooterView = footerView

        tableView.register(cellType: HomeTitleCell.self)
        tableView.register(cellType: HomeDepartmentSelectionCell.self)
        tableView.register(cellType: HomeDepartmentCell.self)
        tableView.register(cellType: HomeStatsCell.self)
    }

    @objc func didPullToRefresh() {
        viewModel.reloadStats()
    }

    private func presentDepartmentSelectionViewController() {
        AppAnalytics.didTapSearchBar()

        let departmentSelectionViewController = DepartmentSelectionViewController.instantiate()
        departmentSelectionViewController.delegate = self
        departmentSelectionViewController.viewModel = DepartmentSelectionViewModel(departments: viewModel.departments)

        DispatchQueue.main.async { [weak self] in
            self?.present(departmentSelectionViewController, animated: true)
        }
    }

    private func presentVaccinationCentresMap() {
        let url = URL(staticString: "https://vitemadose.covidtracker.fr/centres")
        let config = SFSafariViewController.Configuration()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        present(safariViewController, animated: true)
    }

    private func presentMaintenancePage(with urlString: String) {
        let maintenanceViewController = MaintenanceViewController(urlString: urlString)
        present(maintenanceViewController, animated: true)
    }
}

// MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {

    // MARK: Table View Updates

    func reloadTableView(with headingCells: [HomeCell], andStatsCells statsCells: [HomeCell]) {
        var snapshot = Snapshot()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(headingCells, toSection: .heading)
        snapshot.appendItems(statsCells, toSection: .stats)

        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: Present

    func presentVaccinationCentres(for department: Department) {
        viewModel.updateLastSelectedDepartmentIfNeeded(department.codeDepartement)

        let vaccinationCentresViewController = CentresListViewController.instantiate()
        vaccinationCentresViewController.viewModel = CentresListViewModel(department: department)
        navigationController?.show(vaccinationCentresViewController, sender: self)
        AppAnalytics.didSelectDepartment(department)
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

    func presentFetchStatsError(_ error: Error) {
        presentRetryableAndCancellableError(
            error: error,
            retryHandler: { [unowned self] _ in
                self.viewModel.reloadStats()
            },
            cancelHandler: { [unowned self] _ in
                self.refreshControl.endRefreshing()
            },
            completionHandler: nil
        )
    }

    func presentInitialLoadError(_ error: Error) {
        presentRetryableError(
            error: error,
            retryHandler: { [unowned self] _ in
                self.viewModel.load()
            },
            completionHandler: nil
        )
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let homeCell = dataSource.itemIdentifier(for: indexPath) else {
            assertionFailure("HomeCell not found at \(indexPath)")
            return
        }

        switch homeCell {
        case .departmentSelection:
            presentDepartmentSelectionViewController()
        case .department:
            viewModel.didSelectLastDepartment()
            Haptic.impact(.light).generate()
        case let .stats(viewData):
            guard viewData.dataType == .externalMap else {
                return
            }
            presentVaccinationCentresMap()
        default:
            return
        }
    }
}

// MARK: - DataSource

extension HomeViewController {

    private func makeDataSource() -> UITableViewDiffableDataSource<HomeSection, HomeCell> {
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] _, indexPath, homeCell in
                return self?.dequeueAndConfigure(cell: homeCell, at: indexPath)
            }
        )
    }

    private func dequeueAndConfigure(cell: HomeCell, at indexPath: IndexPath) -> UITableViewCell {
        switch cell {
        case let .title(cellViewModel):
            let cell = tableView.dequeueReusableCell(with: HomeTitleCell.self, for: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        case let .departmentSelection(cellViewModel):
            let cell = tableView.dequeueReusableCell(with: HomeDepartmentSelectionCell.self, for: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        case let .department(cellViewModel):
            let cell = tableView.dequeueReusableCell(with: HomeDepartmentCell.self, for: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        case let .stats(cellViewModel):
            let cell = tableView.dequeueReusableCell(with: HomeStatsCell.self, for: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        }
    }
}

// MARK: - DepartmentSelection ViewController Delegate

extension HomeViewController: DepartmentSelectionViewControllerDelegate {

    func didSelect(department: Department) {
        viewModel.didSelect(department)
    }

}
