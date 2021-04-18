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
            title: "Oops, Something Went Wrong :(",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: retryHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)

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
            title: "Oops, Something Went Wrong :(",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: retryHandler)
        alert.addAction(retryAction)

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completionHandler)
        }
    }
}
