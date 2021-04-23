//
//  String.swift
//  ViteMaDose
//
//  Created by PlugN on 22/04/2021.
//

import Foundation

extension String {
<<<<<<< HEAD:ViteMaDose/Helpers/Extensions/String+Commons.swift
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    func format(_ args : CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }
        
    func format(_ args : [String]) -> String {
=======

    // Localization
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }

    func format(_ args: CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }

    func format(_ args: [String]) -> String {
>>>>>>> develop:ViteMaDose/Helpers/Extensions/StringExtension.swift
        return String(format: self, locale: .current, arguments: args)
    }

}
