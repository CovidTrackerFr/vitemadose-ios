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

    private lazy var countySelectionViewController: CountySelectionViewController = {
        let viewController = CountySelectionViewController.instantiate()
        viewController.delegate = self
        return viewController
    }()

    private lazy var vaccinationCentresViewController = VaccinationCentresViewController.instantiate()

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        viewModel.fetchCounties()
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
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .wildSand
        view.backgroundColor = .wildSand
        tableView.tableHeaderView = homeHeaderView
    }

    @IBAction func settingsButtonTapped(_ sender: Any) {
        // TODO: Settings VC
    }
}

// MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    func reloadTableView(isEmpty: Bool) {
        tableView.reloadData()
    }

    func updateLoadingState(isLoading: Bool) {
        // TODO: Loader
    }

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
        countySelectionViewController.viewModel = CountySelectionViewModel(counties: viewModel.counties)
        present(countySelectionViewController.embedInNavigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - CountySelectionViewControllerDelegate

extension HomeViewController: CountySelectionViewControllerDelegate {
    func didSelect(county: County) {
        // TODO: Create ViewModel with County
        vaccinationCentresViewController.title = county.nomDepartement
        navigationController?.show(vaccinationCentresViewController, sender: self)
    }
}
