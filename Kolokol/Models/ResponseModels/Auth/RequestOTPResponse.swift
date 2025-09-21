//
//  RequestOTPResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 20.09.2025.
//

import Foundation

// POST /auth/otp/request
struct RequestOTPResponse : Codable {
    let email: String
    let regToken: UUID
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case email
        case regToken = "reg_token"
        case expiresAt = "expires_at"
    }
}
