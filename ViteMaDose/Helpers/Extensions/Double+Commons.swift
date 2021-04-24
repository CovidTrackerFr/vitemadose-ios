//
//  Double+Commons.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 24/04/2021.
//

import Foundation

extension Double {
    func percentFormatted(locale: Locale = Locale.current) -> String? {
        let number = (self / 100) as NSNumber
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = locale
        return numberFormatter.string(from: number)
    }
}
