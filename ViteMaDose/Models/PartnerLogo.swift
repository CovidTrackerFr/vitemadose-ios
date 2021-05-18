//
//  PartnerLogo.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 13/04/2021.
//

import UIKit

enum PartnerLogo: String, CaseIterable, Equatable {
    case doctolib = "Doctolib"
    case maiia = "Maiia"
    case ordoclic = "Ordoclic"
    case keldoc = "Keldoc"
    case maPharma = "Mapharma"
    case avecMonDoc = "AvecMonDoc"

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
        default:
            return nil
        }
    }
}
