//
//  DepartmentSelectionViewController.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation
import UIKit
import Haptica

protocol DepartmentSelectionViewControllerDelegate: AnyObject {
    func didSelect(location: LocationSearchResult)
}

class DepartmentSelectionViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!
    weak var delegate: DepartmentSelectionViewControllerDelegate?

    var viewModel: DepartmentSelectionViewModel!

    private typealias Snapshot = NSDiffableDataSourceSnapshot<LocationSearchSection, LocationSearchCell>
    private lazy var dataSource = makeDataSource()
    let searchController: UISearchController = UISearchController(searchResultsController: nil)

    private lazy var departmentSelectionHeaderView: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Commune, départment, code postal"
        searchBar.textContentType = .location
        searchBar.delegate = self
        return searchBar
    }()

    private let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("ViewModel was not set for DepartmentSelectionViewController")
        }

        tableView.delegate = self
        tableView.dataSource = dataSource
        viewModel.delegate = self

        view.backgroundColor = .athensGray
        tableView.backgroundColor = .athensGray
        tableView.tableHeaderView = departmentSelectionHeaderView
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(cellType: LocationSearchResultCell.self)

        viewModel.loadDepartments()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.departmentSelect, screenClass: Self.className)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateHeaderViewHeight()
    }
}

// MARK: - UITableViewDataSource

extension DepartmentSelectionViewController {
    private func makeDataSource() -> UITableViewDiffableDataSource<LocationSearchSection, LocationSearchCell> {
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, cell in
                switch cell {
                case let .searchResult(viewData):
                    let cell = tableView.dequeueReusableCell(with: LocationSearchResultCell.self, for: indexPath)
                    cell.configure(with: viewData)
                    return cell
                case .title:
                    return UITableViewCell(frame: .zero)
                }
            }
        )
    }
}

// MARK: - UITableViewDelegate

extension DepartmentSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false
        viewModel.didSelectCell(at: indexPath)
        Haptic.impact(.light).generate()
    }
}

// MARK: - DepartmentSelection ViewModelDelegate

extension DepartmentSelectionViewController: DepartmentSelectionViewModelDelegate {
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

extension DepartmentSelectionViewController: UISearchBarDelegate {
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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    @objc func reload(_ searchBar: UISearchBar) {
        viewModel.search(query: searchBar.text ?? "")
    }
}
