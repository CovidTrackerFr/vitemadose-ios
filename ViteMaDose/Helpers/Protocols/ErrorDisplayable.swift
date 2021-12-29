// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

protocol ErrorDisplayable: AnyObject {
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
