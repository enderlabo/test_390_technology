//
//  Constants.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation

enum AppConstants {
    
    struct APIConfig {
        static let baseURL = URL(string: "https://newsapi.org/v2")!
        }
    }

// MARK: - Errores
enum APIError: Error {
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case cacheError
    case apiKeyDisabled
    case apiKeyExhausted
    case apiKeyInvalid
    case apiKeyMissing
    case parameterInvalid
    case parametersMissing
    case rateLimited
    case sourcesTooMany
    case network(description: String)
    case persistenceError(description: String)
    case unknown
    case missingAPIKey

    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "The request is invalid."
        case .invalidResponse:
            return "The server response is invalid."
        case .httpError(let code, let message):
            return "HTTP Error \(code): \(message)"
        case .decodingError:
            return "There was an error decoding the server response."
        case .cacheError:
            return "Unable to access cached data."
        case .apiKeyDisabled:
            return "Your API key has been disabled."
        case .apiKeyExhausted:
            return "Your API key has exhausted its request quota."
        case .apiKeyInvalid:
            return "Your API key is invalid."
        case .apiKeyMissing:
            return "The API key is missing from the request."
        case .parameterInvalid:
            return "The request includes an invalid parameter."
        case .parametersMissing:
            return "The request is missing required parameters."
        case .rateLimited:
            return "You have exceeded the request limit. Please try again later."
        case .sourcesTooMany:
            return "Too many sources requested in a single request."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        case .network(let description):
           return "Network error: \(description)"
        case .persistenceError(let description):
           return "Persistence error: \(description)"
        case .missingAPIKey:
            return "The API key is missing from the request."
        }
    }
}

