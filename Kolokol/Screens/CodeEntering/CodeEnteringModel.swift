//
//  CodeEnteringModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

final class CodeEnteringModel: CodeEnteringModelProtocol {
    
    var userDefaults: UserDefaultsProtocol
    
    init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
    }
    
    func sendOtpConfirmationRequest(_ request: ConfirmOTPRequest) async throws -> ConfirmOTPResponse {
        let response: ConfirmOTPResponse = try await NetworkService.shared.request(endpoint: Endpoints.authOtpConfirm.rawValue, method: .post, body: request)
        return response
    }
    
    func sendConfirmationCodeAgainRequest(_ request: OTPRequest) async throws -> OTPResponse {
        let response: OTPResponse = try await NetworkService.shared.request(endpoint: Endpoints.authOtpRequest.rawValue, method: .post, body: request)
        return response
    }
    
    func loadCredentialsForTeacher(_ email: String) {
        if email == "kialisaev@edu.hse.ru" {
            userDefaults.saveCredentials(Credentials(name: "Кирилл", lastname: "Исаев", tg: "@mmrdrrr"))
        } else if email == "gsosnovskij@hse.ru" {
            userDefaults.saveCredentials(Credentials(name: "Григорий", lastname: "Сосновский", tg: "@Grizverg"))
        } else if email == "lrezunik@hse.ru" {
            userDefaults.saveCredentials(Credentials(name: "Людмила", lastname: "Резуник", tg: "@lucy_r"))
        }
    }
}
