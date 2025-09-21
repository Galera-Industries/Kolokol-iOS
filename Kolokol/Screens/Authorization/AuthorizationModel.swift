//
//  AuthorizationModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

import Foundation

final class AuthorizationModel: AuthorizationModelProtocol {
    func sendOtpRequest(_ request: OTPRequest) async throws -> OTPResponse {
        let response: OTPResponse = try await NetworkService.shared.request(endpoint: Endpoints.authOtpRequest.rawValue, method: .post, body: request)
        return response
    }
    
    func sendOtpConfirmationRequest(_ request: ConfirmOTPRequest) async throws -> ConfirmOTPResponse {
        let response: ConfirmOTPResponse = try await NetworkService.shared.request(endpoint: Endpoints.authOtpConfirm.rawValue, method: .post, body: request)
        return response
    }
}

