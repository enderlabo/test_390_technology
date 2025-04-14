//
//  Endpoint.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation

struct Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]?
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
}

extension Endpoint {
    static func everything(query: String, apiKey: String) -> Endpoint {
        
        return Endpoint(
            baseURL: URL(string: "https://newsapi.org")!,
            path: "/v2/everything",
            method: .get,
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "apiKey", value: apiKey)
            ],
            headers: nil
        )
    }
}
