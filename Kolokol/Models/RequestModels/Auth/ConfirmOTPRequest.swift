//
//  ConfirmOTPRequest.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

struct ConfirmOTPRequest : Codable {
    let email: String
    let regToken: UUID
    let otp: Int
    
    enum CodingKeys: String, CodingKey {
        case email
        case regToken = "reg_token"
        case otp = "otp4"
    }
}
