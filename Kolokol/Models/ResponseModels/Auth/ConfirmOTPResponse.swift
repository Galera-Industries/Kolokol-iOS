//
//  ConfirmOTPResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 20.09.2025.
//

import Foundation

// POST /auth/otp/confirm
struct ConfirmOTPResponse : Codable {
    let accessToken: String
    let accessTokenExpiration: Date
    let refreshToken: String
    let refreshTokenExpiration: Date
    let role: String
    let profileComplete: Bool?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case accessTokenExpiration = "access_expires"
        case refreshToken = "refresh_token"
        case refreshTokenExpiration = "refresh_expires"
        case role
        case profileComplete = "profile_complete"
    }
}
