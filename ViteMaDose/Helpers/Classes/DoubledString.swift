//
//  DoubledString.swift
//  ViteMaDose
//
//  Created by Pierre-Yves Lapersonne on 01/01/2022.
//

import Foundation

/// Allows to gather two strings in one `Hashable` object
struct DoubledString: Hashable {
    /// The string which can be displayed in the GUI
    let toDisplay: String
    /// The string which can be vocalized with VoiceOver
    let toVocalize: String
}
