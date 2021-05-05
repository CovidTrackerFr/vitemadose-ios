//
//  UIViewController+ErrorDisplayable.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
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
