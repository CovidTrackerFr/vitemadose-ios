//
//  LocationSearchViewController.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation
import UIKit
import Haptica

protocol LocationSearchViewControllerDelegate: AnyObject {
    func didSelect(location: LocationSearchResult)
}

class LocationSearchViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    weak var delegate: LocationSearchViewControllerDelegate?

    var viewModel: LocationSearchViewModel!

    private typealias Snapshot = NSDiffableDataSourceSnapshot<LocationSearchSection, LocationSearchCell>
    private lazy var dataSource = makeDataSource()
    let searchController: UISearchController = UISearchController(searchResultsController: nil)

    private lazy var departmentSelectionHeaderView: LocationSearchHeaderView = {
        let view: LocationSearchHeaderView = LocationSearchHeaderView.instanceFromNib()
        view.searchBar.placeholder = "Commune, départment, code postal"
        view.searchBar.textContentType = .addressCity
        view.searchBar.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("ViewModel was not set for DepartmentSelectionViewController")
        }

        tableView.delegate = self
        tableView.dataSource = dataSource
        viewModel.delegate = self
        tableView.tableHeaderView = departmentSelectionHeaderView

        view.backgroundColor = .athensGray
        tableView.backgroundColor = .athensGray
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(cellType: LocationSearchResultCell.self)

        viewModel.loadDepartments()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.departmentSelect, screenClass: Self.className)
        departmentSelectionHeaderView.searchBar.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateHeaderViewHeight()
    }
}

// MARK: - UITableViewDataSource

extension LocationSearchViewController {
    private func makeDataSource() -> UITableViewDiffableDataSource<LocationSearchSection, LocationSearchCell> {
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, cell in
                switch cell {
                case let .searchResult(viewData):
                    let cell = tableView.dequeueReusableCell(with: LocationSearchResultCell.self, for: indexPath)
                    cell.configure(with: viewData)
                    return cell
                }
            }
        )
    }
}

// MARK: - UITableViewDelegate

extension LocationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false
        viewModel.didSelectCell(at: indexPath)
        Haptic.impact(.light).generate()
    }
}

// MARK: - LocationSearch ViewModelDelegate

extension LocationSearchViewController: LocationSearchViewModelDelegate {
    func reloadTableView(with cells: [LocationSearchCell]) {
        var snapshot = Snapshot()
        snapshot.appendSections(LocationSearchSection.allCases)
        snapshot.appendItems(cells, toSection: .list)

        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func dismissViewController(with location: LocationSearchResult) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelect(location: location)
        }
    }
}

extension LocationSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            viewModel.loadDepartments()
            return
        }
        // Debounce
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(self.reload(_:)),
            object: searchBar
        )
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.3)
    }

    @objc func reload(_ searchBar: UISearchBar) {
        viewModel.search(query: searchBar.text ?? "")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
