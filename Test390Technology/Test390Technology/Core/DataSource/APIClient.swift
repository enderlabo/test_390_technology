//
//  APIClient.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, Error>
}

final class APIClient: APIClientProtocol {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init(urlSession: URLSession = .shared, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, Error> {
        guard let urlRequest = buildRequest(for: endpoint) else {
            return Fail(error: APIError.invalidRequest).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                print("DEBUG: - Data: ",data)
                print("DEBUG: - Response:",response)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.httpError(statusCode: httpResponse.statusCode, message: APIError.invalidRequest.localizedDescription)
                }
                return data
                
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    private func buildRequest(for endpoint: Endpoint) -> URLRequest? {
        var urlComponents = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = endpoint.queryItems
        
        guard let url = urlComponents?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
}
