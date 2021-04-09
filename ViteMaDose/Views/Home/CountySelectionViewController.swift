//
//  CountySelectionViewController.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation
import UIKit

protocol CountySelectionViewControllerDelegate: class {
    func didSelect(county: County)
}

class CountySelectionViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    weak var delegate: CountySelectionViewControllerDelegate?
    
    var viewModel: CountySelectionViewModelProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("ViewModel was not set for CountySelectionViewController")
        }
        tableView.delegate = self
        tableView.dataSource = self
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
        delegate?.didSelect(county: county)
        dismiss(animated: true)
    }
}

extension CountySelectionViewController: CountySelectionViewModelDelegate {
    func reloadTableView(with counties: Counties) {
        tableView.reloadData()
    }
}

