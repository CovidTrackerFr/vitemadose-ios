//
//  UIViewController+ErrorDisplayable.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
//

import UIKit

extension UIViewController: ErrorDisplayable {
    func presentRetryableAndCancellableError(
        error: Error,
        retryHandler: @escaping (UIAlertAction) -> Void,
        cancelHandler: @escaping (UIAlertAction) -> Void,
        completionHandler: (() -> Void)?
    ) {
        let alert = UIAlertController(
            title: LocalizedString.generic_error.title,
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: LocalizedString.generic_error.retry_button, style: .default, handler: retryHandler)
        let cancelAction = UIAlertAction(title: LocalizedString.generic_error.cancel_button, style: .cancel, handler: cancelHandler)

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
            title: LocalizedString.generic_error.title,
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: LocalizedString.generic_error.retry_button, style: .default, handler: retryHandler)
        alert.addAction(retryAction)

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completionHandler)
        }
    }
}
