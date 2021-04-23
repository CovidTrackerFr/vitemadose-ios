//
//  UITableView+Commons.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: bundle)
        register(nib, forCellReuseIdentifier: className)
    }

    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }

    func updateHeaderViewHeight() {
        guard let header = tableHeaderView else {
            return
        }
        let newSize = header.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
        header.frame.size.height = newSize.height
    }
}
