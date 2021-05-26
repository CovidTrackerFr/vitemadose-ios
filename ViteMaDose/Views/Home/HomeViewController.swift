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
import BLTNBoard

final class HomeViewController: UIViewController, Storyboarded {

    @IBOutlet private var tableView: UITableView!

    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func goToSettings(_ sender: Any) {
        presentSettingsViewController()
    }

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

    // TODO: Full onboarding
    private lazy var bulletinManager: BLTNItemManager = {
        let rootItem = OnboardingManager.makeFirstPage()
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.backgroundColor = .tertiarySystemBackground
        manager.backgroundViewStyle = .dimmed
        return manager
    }()

    private lazy var dataSource = makeDataSource()
    private let remoteConfiguration: RemoteConfiguration = .shared

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()

        remoteConfiguration.synchronize { _ in
            self.viewModel.load()
        }

        settingsButton.isAccessibilityElement = true
        settingsButton.accessibilityLabel = Localization.A11y.VoiceOver.Settings.button_label
        settingsButton.accessibilityHint = Localization.A11y.VoiceOver.Settings.button_hint
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.home, screenClass: Self.className)
        viewModel.displayAppOnboardingIfNeeded()
        viewModel.reloadHeadingCellsIfNeeded()
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
        tableView.register(cellType: HomeSearchBarCell.self)
        tableView.register(cellType: HomeSearchResultCell.self)
        tableView.register(cellType: HomeStatsCell.self)
        tableView.register(cellType: HomeFollowedCentresCell.self)
    }

    @objc func didPullToRefresh() {
        viewModel.load()
    }

    private func presentDepartmentSelectionViewController() {
        AppAnalytics.didTapSearchBar()

        let departmentSelectionViewController = LocationSearchViewController.instantiate()
        departmentSelectionViewController.delegate = self
        departmentSelectionViewController.viewModel = LocationSearchViewModel()

        DispatchQueue.main.async { [weak self] in
            self?.present(departmentSelectionViewController, animated: true)
        }
    }

    private func presentSettingsViewController() {
        // TODO: Analytics?
        let settingsViewController = SettingsViewController.instantiate()
        DispatchQueue.main.async { [weak self] in
            self?.present(settingsViewController, animated: true)
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

    private func presentFollowedCentres() {
        let followedCentresViewController = CentresListViewController.instantiate()
        followedCentresViewController.viewModel = FollowedCentresViewModel()
        navigationController?.pushViewController(followedCentresViewController, animated: true)
    }
}

// MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {

    // MARK: Table View Updates

    func reloadTableView(with headingCells: [HomeCell], andStatsCells statsCells: [HomeCell], animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(headingCells, toSection: .heading)
        snapshot.appendItems(statsCells, toSection: .stats)

        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: Present

    func presentVaccinationCentres(for location: LocationSearchResult) {
        let vaccinationCentresViewController = CentresListViewController.instantiate()
        vaccinationCentresViewController.viewModel = CentresListViewModel(searchResult: location)
        navigationController?.show(vaccinationCentresViewController, sender: self)
        AppAnalytics.didSelectLocation(location)
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

    func presentOnboarding() {
        bulletinManager.showBulletin(above: self)
    }

    func presentFetchStatsError(_ error: Error) {
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
        case .searchBar:
            presentDepartmentSelectionViewController()
        case let .searchResult(viewData):
            viewModel.didSelectSavedSearchResult(withName: viewData.name)
            Haptic.impact(.light).generate()
        case .followedCentre:
            presentFollowedCentres()
            Haptic.impact(.light).generate()
        case let .stats(viewData):
            guard viewData.dataType == .externalMap else {
                return
            }
            presentVaccinationCentresMap()
        case .title:
            break
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
        case let .searchBar(cellViewModel):
            let cell = tableView.dequeueReusableCell(with: HomeSearchBarCell.self, for: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        case .followedCentre:
            let cell = tableView.dequeueReusableCell(with: HomeFollowedCentresCell.self, for: indexPath)
            cell.configure()
            return cell
        case let .searchResult(cellViewModel):
            let cell = tableView.dequeueReusableCell(with: HomeSearchResultCell.self, for: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        case let .stats(cellViewModel):
            let cell = tableView.dequeueReusableCell(with: HomeStatsCell.self, for: indexPath)
            cell.configure(with: cellViewModel)
            return cell
        }
    }
}

// MARK: - LocationSearch ViewController Delegate

extension HomeViewController: LocationSearchViewControllerDelegate {

    func didSelect(location: LocationSearchResult) {
        viewModel.didSelect(location)
    }

}
