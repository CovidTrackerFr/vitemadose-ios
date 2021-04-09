//
//  Data+Commons.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

extension Data {
    /// Try do deserialise data into a given object type
    /// - Parameter type: Object type
    func decode<T: Codable>(_ type: T.Type) -> T? {
        let jsonDecoder = JSONDecoder()
        do {
            let response = try jsonDecoder.decode(T.self, from: self)
            return response
        } catch {
            return nil
        }
    }
}
