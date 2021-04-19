//
//  ErrorDisplayable.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
//

import UIKit

protocol ErrorDisplayable: class {
    func presentRetryableAndCancellableError(
        error: Error,
        retryHandler:  @escaping (_: UIAlertAction) -> Void,
        cancelHandler: @escaping (_: UIAlertAction) -> Void,
        completionHandler: (() -> Void)?
    )

    func presentRetryableError(
        error: Error,
        retryHandler:  @escaping (_: UIAlertAction) -> Void,
        completionHandler: (() -> Void)?
    )
}
