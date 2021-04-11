//
//  HomeViewController.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit
import SafariServices

class HomeViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var settingsButton: UIBarButtonItem!

    private lazy var homeHeaderView: HomeHeaderView = {
        let view: HomeHeaderView = HomeHeaderView.instanceFromNib()
        view.delegate = self
        return view
    }()

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

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        viewModel.fetchCounties()
        viewModel.fetchStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateHeaderViewHeight()
    }

    private func configureViewController() {
        view.backgroundColor = .athensGray

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .athensGray
        tableView.alwaysBounceVertical = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        tableView.tableHeaderView = homeHeaderView
        tableView.refreshControl = refreshControl
        tableView.backgroundView = activityIndicator

        tableView.register(cellType: HomeStatsTableViewCell.self)
        tableView.register(cellType: HomePartnersTableViewCell.self)
    }

    @IBAction func settingsButtonTapped(_ sender: Any) {
        // TODO: Settings VC
    }

    @objc func didPullToRefresh() {
        viewModel.fetchStats()
    }
}

// MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    func reloadTableView(isEmpty: Bool) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func updateLoadingState(isLoading: Bool) {
        tableView.tableHeaderView?.isHidden = isLoading
        tableView.tableFooterView?.isHidden = isLoading
        tableView.updateHeaderViewHeight()
        activityIndicator.stopAnimating()
    }

    // TODO: Better error handling
    func displayError(withMessage message: String) {
        let errorAlert = UIAlertController(
            title: "Oops, Something Went Wrong :(",
            message: message,
            preferredStyle: .alert
        )
        present(errorAlert, animated: true)
    }
}

// MARK: - HomeHeaderViewDelegate

extension HomeViewController: HomeHeaderViewDelegate {
    func didTapSearchBarView(_ searchBarView: UIView) {
        let countySelectionViewController = CountySelectionViewController.instantiate()
        countySelectionViewController.delegate = self
        countySelectionViewController.viewModel = CountySelectionViewModel(counties: viewModel.counties)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.present(countySelectionViewController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        switch cellViewModel?.cellType {
            case .stats:
                let cell = tableView.dequeueReusableCell(with: HomeStatsTableViewCell.self, for: indexPath)
                cell.configure(with: cellViewModel as? HomeCellStatsViewModelProvider)
                return cell
            case .logos:
                let cell = tableView.dequeueReusableCell(with: HomePartnersTableViewCell.self, for: indexPath)
                cell.configure()
                return cell
            case .none:
                fatalError("Cell should always have a type")
        }
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Refactor & confirm URL
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        switch cellViewModel?.cellType {
            case .stats:
                guard let viewModel = cellViewModel as? HomeCellStatsViewModelProvider else {
                    return
                }
                if case .externalMap = viewModel.viewData?.dataType {
                    let url = URL(staticString: "https://vitemadose.covidtracker.fr/centres")
                    let config = SFSafariViewController.Configuration()
                    let safariViewController = SFSafariViewController(url: url, configuration: config)
                    present(safariViewController, animated: true)
                }
            default:
                return
        }
    }
}

// MARK: - CountySelectionViewControllerDelegate

extension HomeViewController: CountySelectionViewControllerDelegate {
    func didSelect(county: County) {
        let vaccinationCentresViewController = VaccinationCentresViewController.instantiate()
        vaccinationCentresViewController.viewModel = VaccinationCentresViewModel(county: county)
        navigationController?.show(vaccinationCentresViewController, sender: self)
    }
}
