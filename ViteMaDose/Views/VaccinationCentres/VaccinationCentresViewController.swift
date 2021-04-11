//
//  VaccinationCentresViewController.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import UIKit

class VaccinationCentresViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    var viewModel: VaccinationCentresViewModel!

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.county.nomDepartement
        view.backgroundColor = .athensGray

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .athensGray
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "centre")

        viewModel.delegate = self
        viewModel.fetchVaccinationCentres()
    }

    @objc func didPullToRefresh() {
        viewModel.fetchVaccinationCentres()
    }
}

extension VaccinationCentresViewController: VaccinationCentresViewModelDelegate {
    func reloadTableView(isEmpty: Bool) {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    func updateLoadingState(isLoading: Bool) {

    }

    func displayError(withMessage message: String) {

    }
}

extension VaccinationCentresViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "centre")!
        cell.textLabel?.text = viewModel.cellViewModel(at: indexPath)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

extension VaccinationCentresViewController: UITableViewDelegate {

}
