// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import UIKit

extension URL {
    /// Append a parameter to an URL
    /// - Parameter queryItem: parameter name
    /// - Parameter value: parameter value
    func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        let queryItem = URLQueryItem(name: queryItem, value: value)

        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems

        return urlComponents.url!
    }

    /// Init an URL
    /// - Parameter string: String URL
    init(staticString string: String) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }

    var isValid: Bool {
       return UIApplication.shared.canOpenURL(self)
    }
}
