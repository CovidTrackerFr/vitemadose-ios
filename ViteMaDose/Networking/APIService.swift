//
//  APIService.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 07/04/2021.
//

import Foundation

protocol APIServiceProvider {
	func fetchCounties(_ endPoint: APIEndpoint, completion: @escaping (Result<Counties, APIEndpoint.APIError>) -> ())
	func fetchVaccinationCentres(_ endPoint: APIEndpoint, completion: @escaping (Result<VaccinationCentres, APIEndpoint.APIError>) -> ())
	func cancelRequest()
}

struct APIService: APIServiceProvider {
	let urlSession = URLSession.shared

	func fetchCounties(_ endPoint: APIEndpoint, completion: @escaping (Result<Counties, APIEndpoint.APIError>) -> ()) {
		createRequest(endPoint.path, completion: completion)
	}

	func fetchVaccinationCentres(_ endPoint: APIEndpoint, completion: @escaping (Result<VaccinationCentres, APIEndpoint.APIError>) -> ()) {
		createRequest(endPoint.path, completion: completion)
	}

	func cancelRequest() {
		urlSession.invalidateAndCancel()
	}

	private func createRequest<T: Codable>(_ url: URL, completion: @escaping (Result<T, APIEndpoint.APIError>) -> ()) {
		urlSession.dataTask(with: url) { (data, urlResponse, error) in
			DispatchQueue.main.async {
				if let error = error {
					// Error code -1009: Offline connection
					if (error as NSError).code == -1009 {
						completion(.failure(.noConnection))
						return
					}
					completion(.failure(.apiError))
					return
				}

				// Check if the response code is valid
				// 304: Request resource has not been modified
				if
					let httpResponse = urlResponse as? HTTPURLResponse,
					!(200...299).contains(httpResponse.statusCode) && !(httpResponse.statusCode == 304)
				{
					completion(.failure(.invalidResponse))
					return
				}

				guard let data = data else {
					completion(.failure(.noData))
					return
				}

				guard let decoded = data.decode(T.self) else {
					completion(.failure(.decodeError))
					return
				}

				completion(.success(decoded))
			}
		}.resume()
	}

}
