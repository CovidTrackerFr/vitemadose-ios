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

            let allNotificationsAction = UIAlertAction(title: "Toutes les notifications", style: .default) { [weak self] _ in
                self?.viewModel.requestNotificationsAuthorizationIfNeeded {
                    self?.viewModel.followCentre(at: indexPath, notificationsType: .all)
                }
                Haptic.notification(.success).generate()
                handled(true)
            }

            let chronoDosesNotificationsAction = UIAlertAction(title: "Notifications Chronodoses", style: .default) { [weak self] _ in
                self?.viewModel.requestNotificationsAuthorizationIfNeeded {
                    self?.viewModel.followCentre(at: indexPath, notificationsType: .chronodoses)
                }
                Haptic.notification(.success).generate()
                handled(true)
            }

            let followOnlyAction = UIAlertAction(title: Localization.Location.follow_button, style: .default) { [weak self] _ in
                self?.viewModel.followCentre(at: indexPath, notificationsType: .none)
                Haptic.notification(.success).generate()
                handled(true)
            }

            let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel) { _ in
                handled(true)
            }

            bottomSheet.addAction(allNotificationsAction)
            bottomSheet.addAction(chronoDosesNotificationsAction)
            bottomSheet.addAction(followOnlyAction)
            bottomSheet.addAction(cancelAction)
            bottomSheet.popoverPresentationController?.sourceView = view

            self?.present(bottomSheet, animated: true)
        }

        action.image = UIImage(systemName: "bell.fill")?.tint(with: .label)
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

        action.image = UIImage(systemName: "bell.slash.fill")?.tint(with: .label)
        action.backgroundColor = .athensGray
        return action
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            tableView.cellForRow(at: indexPath)?.layoutIfNeeded()
        }
    }
}
