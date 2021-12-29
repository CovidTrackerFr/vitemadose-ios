// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import SwiftDate

enum AppConstant {
    static let franceRegion = Region(
        calendar: Calendar.current,
        zone: Zones.current,
        locale: Locale(identifier: "fr_FR")
    )
}
