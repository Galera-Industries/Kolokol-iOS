//
//  Endpoints.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

enum Endpoints: String {
    /// Auth endpoints
    /// enjoy!
    case authOtpRequest = "/auth/otp/request"
    case authOtpConfirm = "/auth/otp/confirm"
    case authRefresh = "/auth/refresh"
}
