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
    func decode<T: Codable>(_ type: T.Type) -> Result<T, Error> {
        let jsonDecoder = JSONDecoder()
        do {
            let decoded = try jsonDecoder.decode(T.self, from: self)
            return .success(decoded)
        } catch {
            #if DEBUG
            logDecodeError(error)
            #endif
            return .failure(error)
        }
    }

    private func logDecodeError(_ error: Error) {
        switch error {
        case let DecodingError.dataCorrupted(context):
            print(context)
        case let DecodingError.keyNotFound(key, context):
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        case let DecodingError.valueNotFound(value, context):
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        case let DecodingError.typeMismatch(type, context):
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        default:
            print("Unknown:", error.localizedDescription)
        }
    }
}
