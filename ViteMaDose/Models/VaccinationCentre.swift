// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import MapKit
import PhoneNumberKit
import SwiftDate

// MARK: - Vaccination Centre

public struct VaccinationCentre: Codable, Hashable, Identifiable {
    private let gid: String?
    public let internalId: String?
    let departement: String?
    let nom: String?
    let url: String?
    let location: Location?
    let metadata: Metadata?
    let prochainRdv: String?
    let plateforme: String?
    let type: CentreType?
    let vaccineType: [String]?
    let appointmentSchedules: [AppointmentSchedule?]?

    public var id: String {
        return internalId ?? gid ?? UUID().uuidString
    }

    enum CodingKeys: String, CodingKey {
        case internalId = "internal_id"
        case gid
        case departement
        case nom
        case url
        case location
        case metadata
        case prochainRdv = "prochain_rdv"
        case plateforme
        case type
        case vaccineType = "vaccine_type"
        case appointmentSchedules = "appointment_schedules"
    }
}

extension VaccinationCentre {

    // MARK: Location

    struct Location: Codable, Hashable {
        let longitude: Double?
        let latitude: Double?
        let city: String?

        enum CodingKeys: String, CodingKey {
            case longitude
            case latitude
            case city
        }
    }

    // MARK: Metadata

    struct Metadata: Codable, Hashable {
        let address: String?
        let phoneNumber: String?
        let businessHours: [String: String?]?

        enum CodingKeys: String, CodingKey {
            case address
            case phoneNumber = "phone_number"
            case businessHours = "business_hours"
        }
    }

    // MARK: Appointment Schedule

    struct AppointmentSchedule: Codable, Hashable {
        let name: String?
        let from: String?
        let to: String?
        let total: Int?

        enum CodingKeys: String, CodingKey {
            case name
            case from
            case to
            case total
        }
    }

    // MARK: Centre Type

    public enum CentreType: String, Codable, Hashable {
        case vaccinationCenter = "vaccination-center"
        case drugstore = "drugstore"
        case generalPractitioner = "general-practitioner"
        case medecin = "medecin"

        public init?(rawValue: String) {
            switch rawValue {
            case "vaccination-center":
                self = .vaccinationCenter
            case "drugstore":
                self = .drugstore
            case "general-practitioner":
                self = .generalPractitioner
            case "medecin":
                self = .medecin
            default:
                assertionFailure("Received value '\(rawValue) but it's not managed")
                return nil
            }
        }

        var localized: String {
            switch self {
            case .vaccinationCenter:
                return Localization.Location.Types.vaccination_center
            case .drugstore:
                return Localization.Location.Types.drugstore
            case .generalPractitioner:
                return Localization.Location.Types.general_practicioner
            case .medecin:
                return Localization.Location.Types.medecin
            }
        }
    }
}

// MARK: Sequence of Vaccination Centre

extension Sequence where Element == VaccinationCentre {
    var allAvailableCentresCount: Int {
        return reduce(0) { $0 + $1.isAvailable.intValue }
    }
}

// MARK: - Vaccination Centre - computed properties

extension VaccinationCentre {
    var isAvailable: Bool {
        return prochainRdv != nil
    }

    var nextAppointmentDate: Date? {
        return prochainRdv?.toDate(nil, region: AppConstant.franceRegion)?.date ?? prochainRdv?.toISODate(nil, region: AppConstant.franceRegion)?.date
    }

    var nextAppointmentDay: String? {
        return prochainRdv?.toString(with: .date(.long), region: AppConstant.franceRegion)
    }

    var nextAppointmentTime: String? {
        return prochainRdv?.toString(with: .time(.short), region: AppConstant.franceRegion)
    }

    var appointmentUrl: URL? {
        guard
            let urlString = self.url,
            let url = URL(string: urlString),
            url.isValid
        else {
            return nil
        }
        return URL(string: urlString)
    }

    var phoneUrl: URL? {
        guard
            let phoneNumber = metadata?.phoneNumber,
            let phoneNumberUrl = URL(string: "tel://\(phoneNumber)"),
            phoneNumberUrl.isValid
        else {
            return nil
        }
        return phoneNumberUrl
    }

    var locationAsCLLocation: CLLocation? {
        guard
            let latitude = location?.latitude,
            let longitude = location?.longitude
        else {
            return nil
        }
        return CLLocation(
            latitude: latitude,
            longitude: longitude
        )
    }

    var vaccinesTypeText: String? {
        guard let vaccineType = vaccineType, !vaccineType.isEmpty else {
            return nil
        }
        return vaccineType.joined(separator: String.commaWithSpace)
    }

    static var sortedByAppointment: (Self, Self) -> Bool = {
        guard
            let lhsDate = $0.nextAppointmentDate,
            let rhsDate = $1.nextAppointmentDate,
            $0.isAvailable,
            $1.isAvailable
        else {
            return false
        }
        return lhsDate.isBeforeDate(rhsDate, granularity: .minute)
    }

    func formattedCentreName(selectedLocation: CLLocation?) -> String {
        guard var name = nom else {
            return Localization.Location.unavailable_name
        }

        if
            let location = locationAsCLLocation,
            let selectedLocation = selectedLocation
        {
            // Add distance in kilometres
            let distanceInKm = location.distance(from: selectedLocation) / 1000
            let formattedDistance = String(format: "%.1f", distanceInKm)
            name.append(String.space + "(\(formattedDistance) km)")
        }

        return name
    }

    func formattedPhoneNumber(_ phoneNumberKit: PhoneNumberKit) -> String? {
        guard let metaDataPhoneNumber = metadata?.phoneNumber else { return nil }
        let parsedPhoneNumber = try? phoneNumberKit.parse(
            metaDataPhoneNumber,
            withRegion: "FR",
            ignoreType: true
        )
        guard let phoneNumber = parsedPhoneNumber else { return nil }
        return phoneNumberKit.format(phoneNumber, toType: .national)
    }
}

// MARK: - Vaccination Centres

struct VaccinationCentres: Codable, Hashable {
    let lastUpdated: String?
    private let centresDisponibles: [VaccinationCentre]
    private let centresIndisponibles: [VaccinationCentre]

    var availableCentres: [VaccinationCentre] {
        return centresDisponibles.uniqued()
    }

    var unavailableCentres: [VaccinationCentre] {
        return centresIndisponibles.uniqued()
    }

    var formattedLastUpdated: String? {
        guard let lastUpdateDate = lastUpdated?.toDate(nil, region: AppConstant.franceRegion) else {
            return nil
        }

        let lastUpdateDay = lastUpdateDate.toString(.date(.short))
        let lastUpdateTime = lastUpdateDate.toString(.time(.short))

        return Localization.Location.last_update.format(lastUpdateDay, lastUpdateTime)
    }

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case centresDisponibles = "centres_disponibles"
        case centresIndisponibles = "centres_indisponibles"
    }
}

// MARK: - Department Vaccination Centres

typealias DepartmentVaccinationCentres = [VaccinationCentres]

extension DepartmentVaccinationCentres {
    var allAvailableCentres: [VaccinationCentre] {
        return flatMap(\.availableCentres).unique(by: \.id)
    }

    var allUnavailableCentres: [VaccinationCentre] {
        return flatMap(\.unavailableCentres).unique(by: \.id)
    }
}
