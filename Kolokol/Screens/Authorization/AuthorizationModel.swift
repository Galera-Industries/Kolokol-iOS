//
//  AuthorizationModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

import Foundation

final class AuthorizationModel: AuthorizationModelProtocol {
    func sendOtpRequest(_ request: OtpRequest) async throws -> OtpResponse {
        return OtpResponse(email: "Mock", regToken: UUID(), expiresAt: Date())
    }
    
    func sendOtpConfirmationRequest(_ request: ConfirmOtpResponse) async throws -> ConfirmOtpResponse {
        return ConfirmOtpResponse(
            email: "Mock",
            role: .student,
            accessToken: UUID(),
            accessExpires: Date(),
            refreshToken: UUID(),
            refreshExpires: Date(),
            profileComplete: false
        )
    }
}

struct OtpRequest: Codable {
    let email: String
}

struct OtpResponse: Codable {
    let email: String
    let regToken: UUID
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case email
        case regToken = "reg_token"
        case expiresAt = "expiresAt"
    }
}

struct CofirmOtpRequest: Codable {
    let email: String
    let regToken: UUID
    let otp4: Int
    
    enum CodingKeys: String, CodingKey {
        case email
        case regToken = "reg_token"
        case otp4
    }
}

struct ConfirmOtpResponse: Codable {
    let email: String
    let role: StudentRole
    let accessToken: UUID
    let accessExpires: Date
    let refreshToken: UUID
    let refreshExpires: Date
    let profileComplete: Bool?
    
    enum CodingKeys: String, CodingKey {
        case email
        case role
        case accessToken = "access_token"
        case accessExpires = "access_expires"
        case refreshToken = "refresh_token"
        case refreshExpires = "refresh_expires"
        case profileComplete = "profile_complete"
    }
}

struct RefreshTokenRequest: Codable {
    let refreshToken: UUID
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct RefreshTokenResponse: Codable {
    let accessToken: UUID
    let accessExpires: Date
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case accessExpires = "access_expires"
    }
}

enum StudentRole: Codable {
    case student
    case teacher
}
