//
//  CachePolicyPlugin.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 01/05/2021.
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
