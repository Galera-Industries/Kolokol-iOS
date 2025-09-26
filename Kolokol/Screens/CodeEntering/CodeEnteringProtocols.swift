//
//  CodeEnteringProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

protocol CodeEnteringModelProtocol {
    func sendOtpConfirmationRequest(_ request: ConfirmOTPRequest) async throws -> ConfirmOTPResponse
    func sendConfirmationCodeAgainRequest(_ request: OTPRequest) async throws -> OTPResponse
    func loadCredentialsForTeacher(_ email: String)
}

protocol CodeEnteringViewProtocol: AnyObject {
    func showError(_ error: String)
    func routeNext(_ isComplete: Bool, _ isTeacher: Bool)
}

protocol CodeEnteringPresenterProtocol {
    func textFieldFilled(withStringCode stringCode: String)
    func sendCodePressed()
}
