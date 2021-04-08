//
//  APIEndpoint.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

protocol EndpointType {
    var baseURL: URL { get }
    var path: URL { get }
}

enum APIEndpoint {
    case counties
    case vaccinationCentres(county: String)
}

extension APIEndpoint: EndpointType {
    var baseURL: URL {
        return URL(staticString: "https://raw.githubusercontent.com/CovidTrackerFr/vitemadose/data-auto/data/output/")
    }
    
    var path: URL {
        switch self {
            case .counties:
                return baseURL.appendingPathComponent("departements.json")
            case let .vaccinationCentres(county):
                return baseURL.appendingPathComponent("\(county).json")
        }
    }
}

extension APIEndpoint {
    enum APIError: Error {
        case apiError
        case noConnection
        case invalidEndpoint
        case invalidResponse
        case noData
        case decodeError
        case unknown
        
        var localizedDescription: String {
            switch self {
                case .apiError, .invalidEndpoint:
                    return "We are having troubles with our server right now. Please try again later"
                case .noConnection:
                    return "Your Internet connection appears to be offline."
                case .invalidResponse, .noData:
                    return "We could not fetch the data, please try again"
                default:
                    return "An error occurred, please try again"
            }
        }
    }
}
