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

	lazy var homeHeaderView: HomeHeaderView = {
		let view: HomeHeaderView = HomeHeaderView.instanceFromNib()
		view.delegate = self
        view.configure()
		return view
	}()

	lazy var viewModel: HomeViewModelProvider = {
		let viewModel = HomeViewModel()
		viewModel.delegate = self
		return viewModel
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.tableHeaderView = homeHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }
}

// MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
	func updateLoadingState(isLoading: Bool) {

	}

	func reloadTableView(isEmpty: Bool) {
		tableView.reloadData()
	}

	func displayError(withMessage message: String) {
		let errorAlert = UIAlertController(title: "Oops, Something Went Wrong :(", message: message, preferredStyle: .alert)
		present(errorAlert, animated: true)
	}

    func countySelected(_ county: County) {
        homeHeaderView.countySelected(county)
        viewModel.fetchVaccinationCentre(for: county)
    }
}

// MARK: - HomeHeaderViewDelegate

extension HomeViewController: HomeHeaderViewDelegate {
	func didSelect() {

        let storyboard = UIStoryboard(name: "HomeViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CountySelectionViewController") as! CountySelectionViewController
        vc.delegate = self
        self.present(vc, animated: true)

//		viewModel.fetchVaccinationCentre(for: county)
	}
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfRows
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
		let cellViewModel = viewModel.cellViewModel(at: indexPath)
		cell.textLabel?.text = cellViewModel?.nom
		cell.detailTextLabel?.text = cellViewModel?.plateforme
		return cell
	}
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let bookingUrl = viewModel.bookingLink(at: indexPath) else {
			// TODO: Error
			return
		}

		let safariViewControllerConfig = SFSafariViewController.Configuration()
		let safariViewController = SFSafariViewController(url: bookingUrl, configuration: safariViewControllerConfig)
		present(safariViewController, animated: true)
	}
}

