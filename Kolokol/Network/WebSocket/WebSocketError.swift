//
//  WebSocketError.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

enum WebSocketError : LocalizedError {
    case badURL
    var errorDescription: String? {
        switch self {
        case .badURL: return "Invalid WebSocket URL"
        }
    }
}
