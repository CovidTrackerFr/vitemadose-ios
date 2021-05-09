//
//  CentresListViewController+TableViewActions.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 08/05/2021.
//

import UIKit
import Haptica

extension CentresListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let isCentreFollowed = viewModel.isCentreFollowed(at: indexPath) else {
            return UISwipeActionsConfiguration(actions: [])
        }

        let actions = isCentreFollowed ? [unfollowAction(at: indexPath)] : [followAction(at: indexPath)]
        let config = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = false

        return config
    }

    private func followAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: Localization.Location.follow_action_title) { [weak self] _, view, handled in
            let bottomSheet = UIAlertController(
                title: Localization.Location.start_following_title,
                message: Localization.Location.start_following_message,
                preferredStyle: .actionSheet
            )

            let notifyAction = UIAlertAction(title: Localization.Location.notify_button, style: .default) { [weak self] _ in
                self?.viewModel.requestNotificationsAuthorizationIfNeeded {
                    self?.viewModel.followCentre(at: indexPath, watch: true)
                }
                Haptic.notification(.success).generate()
                handled(true)
            }

            let followAction = UIAlertAction(title: Localization.Location.follow_button, style: .default) { [weak self] _ in
                self?.viewModel.followCentre(at: indexPath, watch: false)
                Haptic.notification(.success).generate()
                handled(true)
            }

            let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel) { _ in
                handled(true)
            }

            bottomSheet.addAction(notifyAction)
            bottomSheet.addAction(followAction)
            bottomSheet.addAction(cancelAction)
            bottomSheet.popoverPresentationController?.sourceView = view

            self?.present(bottomSheet, animated: true)
        }

        action.image = UIImage(systemName: "bookmark.fill")?.tint(with: .label)
        action.backgroundColor = .athensGray
        return action
    }

    private func unfollowAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: Localization.Location.unfollow_action_title) { [weak self] _, view, handled in
            let bottomSheet = UIAlertController(
                title: Localization.Location.stop_following_title,
                message: Localization.Location.stop_following_message,
                preferredStyle: .actionSheet
            )

            let unfollowAction = UIAlertAction(title: Localization.Location.stop_following_button, style: .destructive) { [weak self] _ in
                self?.viewModel.unfollowCentre(at: indexPath)
                Haptic.impact(.medium).generate()
                handled(true)
            }

            let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel) { _ in
                handled(true)
            }

            bottomSheet.addAction(unfollowAction)
            bottomSheet.addAction(cancelAction)
            bottomSheet.popoverPresentationController?.sourceView = view

            self?.present(bottomSheet, animated: true)
        }

        action.image = UIImage(systemName: "bookmark")?.tint(with: .label)
        action.backgroundColor = .athensGray
        return action
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            tableView.cellForRow(at: indexPath)?.layoutIfNeeded()
        }
    }
}

extension UITableViewCell {
    var cellActionButtonLabel: UILabel? {
        superview?.subviews
            .filter { String(describing: $0).range(of: "UISwipeActionPullView") != nil }
            .flatMap { $0.subviews }
            .filter { String(describing: $0).range(of: "UISwipeActionStandardButton") != nil }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UILabel }.first
    }
}
