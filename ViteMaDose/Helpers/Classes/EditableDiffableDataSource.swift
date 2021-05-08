//
//  EditableDiffableDataSource.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 08/05/2021.
//

import Foundation
import UIKit

/// `UITableViewDiffableDataSource` disables `canEditRowAt` by default
/// This generic subclass overrides `canEditRowAt` to return true

final class EditableDiffableDataSource<S: CaseIterable & Hashable, L: Hashable>: UITableViewDiffableDataSource<S, L> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
