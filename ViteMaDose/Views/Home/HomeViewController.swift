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
    @IBOutlet weak var logoContainerView: UIView!
    
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

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()

        RemoteConfiguration.shared.synchronize { [unowned self] _ in
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
        tableView.register(cellType: HomeCountySelectionCell.self)
        tableView.register(cellType: HomeCountyCell.self)
        tableView.register(cellType: HomeStatsCell.self)
        
        logoContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLogoContainerView)))
    }

    @objc func didPullToRefresh() {
        viewModel.reloadStats()
    }
    
    @objc func didTapLogoContainerView() {
        presentCreditViewController()
    }

    private func presentCountySelectionViewController() {
        AppAnalytics.didTapSearchBar()

        let countySelectionViewController = CountySelectionViewController.instantiate()
        countySelectionViewController.delegate = self
        countySelectionViewController.viewModel = CountySelectionViewModel(counties: viewModel.counties)

        DispatchQueue.main.async { [weak self] in
            self?.present(countySelectionViewController, animated: true)
        }
    }

    private func presentVaccinationCentresMap() {
        let url = URL(staticString: "https://vitemadose.covidtracker.fr/centres")
        let config = SFSafariViewController.Configuration()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        present(safariViewController, animated: true)
    }
    
    private func presentCreditViewController() {
        let creditViewController = CreditViewController.instantiate()
        creditViewController.viewModel = CreditViewModel(credits: [
            Credit(nom: "Victor Sarda", image: "https://github.com/victor-sarda.png"),
            Credit(nom: "Paul Jeannot", image: "https://github.com/pauljeannot.png"),
            Credit(nom: "Nathan Fallet", image: "https://github.com/NathanFallet.png"),
            Credit(nom: "Guillaume Rozier", image: "https://github.com/rozierguillaume.png"),
        ])
        
        DispatchQueue.main.async { [weak self] in
            self?.present(creditViewController, animated: true)
        }
    }
}

// MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {

    // MARK: Table View Updates

    func reloadTableView(with headingCells: [HomeCell], andStatsCells: [HomeCell]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(headingCells, toSection: .heading)
        snapshot.appendItems(andStatsCells, toSection: .stats)

        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func reloadHeadingSection(with headingCells: [HomeCell]) {
        let snapshot = dataSource.snapshot()

        // Create a new snapshot with current stats cells
        // Apply heading changes
        var update = Snapshot()
        update.appendSections(HomeSection.allCases)
        update.appendItems(snapshot.itemIdentifiers(inSection: .stats), toSection: .stats)
        update.appendItems(headingCells, toSection: .heading)

        dataSource.apply(update, animatingDifferences: true)
    }

    func reloadStatsSection(with statsCells: [HomeCell]) {
        let snapshot = dataSource.snapshot()

        // Create a new snapshot with current heading cells
        // Apply stats changes
        var update = Snapshot()
        update.appendSections(HomeSection.allCases)
        update.appendItems(snapshot.itemIdentifiers(inSection: .heading), toSection: .heading)
        update.appendItems(statsCells, toSection: .stats)

        dataSource.apply(update, animatingDifferences: true)
    }

    // MARK: Present

    func presentVaccinationCentres(for county: County) {
        viewModel.updateLastSelectedCountyIfNeeded(county.codeDepartement)

        let vaccinationCentresViewController = CentresListViewController.instantiate()
        vaccinationCentresViewController.viewModel = CentresListViewModel(county: county)
        navigationController?.show(vaccinationCentresViewController, sender: self)
        AppAnalytics.didSelectCounty(county)
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
            case .countySelection:
                presentCountySelectionViewController()
            case .county:
                viewModel.didSelectLastCounty()
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
            cellProvider: { [weak self] tableView, indexPath, homeCell in
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
            case let .countySelection(cellViewModel):
                let cell = tableView.dequeueReusableCell(with: HomeCountySelectionCell.self, for: indexPath)
                cell.configure(with: cellViewModel)
                return cell
            case let .county(cellViewModel):
                let cell = tableView.dequeueReusableCell(with: HomeCountyCell.self, for: indexPath)
                cell.configure(with: cellViewModel)
                return cell
            case let .stats(cellViewModel):
                let cell = tableView.dequeueReusableCell(with: HomeStatsCell.self, for: indexPath)
                cell.configure(with: cellViewModel)
                return cell
        }
    }
}

// MARK: - CountySelectionViewControllerDelegate

extension HomeViewController: CountySelectionViewControllerDelegate {

    func didSelect(county: County) {
        viewModel.didSelect(county)
    }

}
