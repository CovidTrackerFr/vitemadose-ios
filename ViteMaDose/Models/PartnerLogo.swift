// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit

enum PartnerLogo: String, CaseIterable, Equatable {
    case doctolib = "Doctolib"
    case maiia = "Maiia"
    case ordoclic = "Ordoclic"
    case keldoc = "Keldoc"
    case maPharma = "Mapharma"
    case avecMonDoc = "AvecMonDoc"
    case meSoigner = "mesoigner"
    case bimedoc = "bimedoc"
    case valwin = "Valwin"

    var image: UIImage? {
        switch self {
        case .doctolib:
            return UIImage(named: PartnerLogo.doctolib.rawValue)
        case .maiia:
            return UIImage(named: PartnerLogo.maiia.rawValue)
        case .ordoclic:
            return UIImage(named: PartnerLogo.ordoclic.rawValue)
        case .keldoc:
            return UIImage(named: PartnerLogo.keldoc.rawValue)
        case .maPharma:
            return UIImage(named: PartnerLogo.maPharma.rawValue)
        case .avecMonDoc:
            return UIImage(named: PartnerLogo.avecMonDoc.rawValue)
        case .meSoigner:
            return UIImage(named: PartnerLogo.meSoigner.rawValue)
        case .bimedoc:
            return UIImage(named: PartnerLogo.bimedoc.rawValue)
        case .valwin:
            return UIImage(named: PartnerLogo.valwin.rawValue)
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case PartnerLogo.doctolib.rawValue:
            self = .doctolib
        case PartnerLogo.maiia.rawValue:
            self = .maiia
        case PartnerLogo.ordoclic.rawValue:
            self = .ordoclic
        case PartnerLogo.keldoc.rawValue:
            self = .keldoc
        case PartnerLogo.maPharma.rawValue:
            self = .maPharma
        case PartnerLogo.avecMonDoc.rawValue:
            self = .avecMonDoc
        case PartnerLogo.meSoigner.rawValue:
            self = .meSoigner
        case PartnerLogo.bimedoc.rawValue:
            self = .bimedoc
        case PartnerLogo.valwin.rawValue:
            self = .valwin
        default:
            return nil
        }
    }
}
