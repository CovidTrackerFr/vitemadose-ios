//
//  CountySelectionViewController.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation
import UIKit

class CountySelectionViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    var delegate: HomeViewModelDelegate!
    
    lazy var viewModel: CountySelectionViewModelProvider = {
        let viewModel = CountySelectionViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.fetchCounties()
    }
}

// MARK: - UITableViewDataSource

extension CountySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let cellViewModel = viewModel.cellViewModel(at: indexPath)!
        cell.textLabel?.text = "\(cellViewModel.codeDepartement!) - \(cellViewModel.nomDepartement!)"
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CountySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let county = viewModel.cellViewModel(at: indexPath) else {
            fatalError("Unexpected indexPath for county selection: \(indexPath)")
        }
        delegate.countySelected(county)
        dismiss(animated: true)
    }
}

extension CountySelectionViewController: CountySelectionViewModelDelegate {
    func updateLoadingState(isLoading: Bool) {
        print("loading state")
    }
    
    func reloadTableView(with counties: Counties) {
        tableView.reloadData()
    }
    
    func displayError(withMessage message: String) {
        let errorAlert = UIAlertController(title: "Oops, Something Went Wrong :(", message: message, preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.fetchCounties()
        })
        
        present(errorAlert, animated: true)
    }
}

