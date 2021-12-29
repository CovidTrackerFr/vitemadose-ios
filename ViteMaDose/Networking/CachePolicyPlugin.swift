// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import Moya

protocol CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class CachePolicyPlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let cachePolicyGettable = target as? CachePolicyGettable else {
            return request
        }

        var mutableRequest = request
        mutableRequest.cachePolicy = cachePolicyGettable.cachePolicy
        return mutableRequest
    }
}
