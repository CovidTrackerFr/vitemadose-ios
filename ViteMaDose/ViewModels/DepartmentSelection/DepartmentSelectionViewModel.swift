//
//  DepartmentSelectionViewModel.swift
//  ViteMaDose
//
//  Created by Paul Jeannot on 08/04/2021.
//

import Foundation

protocol DepartmentSelectionViewModelProvider {
    var numberOfRows: Int { get }
    func cellViewModel(at indexPath: IndexPath) -> DepartmentCellViewDataProvider?
    func didSelectCell(at indexPath: IndexPath)
}

protocol DepartmentSelectionViewModelDelegate: AnyObject {
    func reloadTableView(with departments: Departments)
    func dismissViewController(with department: Department)
}

class DepartmentSelectionViewModel: DepartmentSelectionViewModelProvider {
    private let userDefaults: UserDefaults
    weak var delegate: DepartmentSelectionViewModelDelegate?

    private var departments: [Department] = []

    var numberOfRows: Int {
        departments.count
    }

    // MARK: init

    required init(
        departments: Departments,
        userDefaults: UserDefaults = .shared
    ) {
        self.departments = departments
        self.userDefaults = userDefaults

        delegate?.reloadTableView(with: departments)
    }

    func cellViewModel(at indexPath: IndexPath) -> DepartmentCellViewDataProvider? {
        guard let department = departments[safe: indexPath.row] else {
            assertionFailure("No department found at IndexPath \(indexPath)")
            return nil
        }

        guard let name = department.nomDepartement,
              let code = department.codeDepartement
        else {
            return nil
        }

        return DepartmentCellViewData(
            name: name,
            code: code
        )
    }

    func didSelectCell(at indexPath: IndexPath) {
        guard let department = departments[safe: indexPath.row] else {
            assertionFailure("Department not found at indexPath \(indexPath)")
            return
        }

        userDefaults.lastSelectedDepartmentCode = department.codeDepartement
        delegate?.dismissViewController(with: department)
    }
}
