// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

extension UICollectionView {
    public func register<T: UICollectionViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: className)
    }

    public func register<T: UICollectionViewCell>(cellTypes: [T.Type], bundle: Bundle? = nil) {
        cellTypes.forEach { register(cellType: $0, bundle: bundle) }
    }

    public func register<T: UICollectionReusableView>(
        reusableViewType: T.Type,
        ofKind kind: String = UICollectionView.elementKindSectionHeader,
        bundle: Bundle? = nil
    ) {
        let className = reusableViewType.className
        let nib = UINib(nibName: className, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }

    public func register<T: UICollectionReusableView>(
        reusableViewTypes: [T.Type],
        ofKind kind: String = UICollectionView.elementKindSectionHeader,
        bundle: Bundle? = nil
    ) {
        reusableViewTypes.forEach { register(reusableViewType: $0, ofKind: kind, bundle: bundle) }
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(
        with type: T.Type,
        for indexPath: IndexPath
    ) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.className, for: indexPath) as! T
    }

    public func dequeueReusableView<T: UICollectionReusableView>(
        with type: T.Type,
        for indexPath: IndexPath,
        ofKind kind: String = UICollectionView.elementKindSectionHeader
    ) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.className, for: indexPath) as! T
    }
}
