//
//  ClassNameProtocol.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

protocol ClassNameProtocol {
    static var className: String { get }
}

/// Get a string from the object name
extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
}

/// Apply the protocol to any NSObject
extension NSObject: ClassNameProtocol { }
