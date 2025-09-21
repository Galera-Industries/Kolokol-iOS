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
}

