//
//  NewsError.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 29/09/2025.
//

import Foundation

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}


enum NewsError: LocalizedError {
    case invalidURL
    case invalidServerResponse
    case decodingError
    case databaseError(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidServerResponse:
            return "The server returned an invalid response. Please try again later."
        case .decodingError:
            return "There was a problem processing the news data."
        case .databaseError(let message):
            return "Database error: \(message)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
