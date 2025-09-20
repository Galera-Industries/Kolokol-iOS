//
//  NetworkError.swift
//  Kolokol
//
//  Created by Tom Tim on 20.09.2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case noData
    case decodingError
    case internalServerError
    case unknown(message: String?)
    case forbidden
    case notFound
    case invalidURL
    case invalidCode
    
    private static let errorMapping: [String: NetworkError] = [
        "InvalidURL": .invalidURL,
        "NoData": .noData,
        "DecodingError": .decodingError,
        "InternalServerError": .internalServerError,
        "Forbidden": .forbidden,
        "otp invalid or expired": .invalidCode
    ]
    
    init?(message: String) {
        if let mappedError = NetworkError.errorMapping[message] {
            self = mappedError
        } else {
            self = .unknown(message: message)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data from server"
        case .decodingError:
            return "Error while decoding server response"
        case .internalServerError:
            return "ААААААА ВЛАД ПОЧИНИИИИИ\n(напишите пожалуйста о произошеддшем нам, мы всё починим...)"
        case .forbidden:
            return "Доступ запрещён"
        case .notFound:
            return "Не найдено"
        case .invalidCode:
            return "Неверный или просроченный код"
        case .unknown(let message):
            return message ?? "Произошла неизвестная ошибка"
        }
    }
}
