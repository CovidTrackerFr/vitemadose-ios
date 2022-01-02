// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation

/// Allows to gather two strings in one `Hashable` object
struct DoubledString: Hashable {
    /// The string which can be displayed in the GUI
    let toDisplay: String
    /// The string which can be vocalized with VoiceOver
    let toVocalize: String
}
