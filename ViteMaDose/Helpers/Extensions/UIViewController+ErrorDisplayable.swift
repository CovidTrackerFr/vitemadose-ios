// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit
import Moya

extension UIViewController: ErrorDisplayable {
    func presentRetryableAndCancellableError(
        error: Error,
        retryHandler: @escaping (UIAlertAction) -> Void,
        cancelHandler: @escaping (UIAlertAction) -> Void,
        completionHandler: (() -> Void)?
    ) {
        let alert = UIAlertController(
            title: Localization.Error.Generic.title,
            message: errorMessage(for: error),
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: Localization.Error.Generic.retry_button, style: .default, handler: retryHandler)
        let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel, handler: cancelHandler)

        alert.addAction(cancelAction)
        alert.addAction(retryAction)

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completionHandler)
        }
    }

    func presentRetryableError(
        error: Error,
        retryHandler: @escaping (UIAlertAction) -> Void,
        completionHandler: (() -> Void)?
    ) {
        let alert = UIAlertController(
            title: Localization.Error.Generic.title,
            message: errorMessage(for: error),
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: Localization.Error.Generic.retry_button, style: .default, handler: retryHandler)
        alert.addAction(retryAction)

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completionHandler)
        }
    }

    private func errorMessage(for error: Error) -> String {
      // TODO: Error handling
        return Localization.Error.Generic.default_message
    }
}
