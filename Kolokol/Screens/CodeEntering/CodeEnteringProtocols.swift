//
//  CodeEnteringProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

protocol CodeEnteringModelProtocol {
    func sendOtpConfirmationRequest(_ request: ConfirmOTPRequest) async throws -> ConfirmOTPResponse
}

protocol CodeEnteringViewProtocol: AnyObject {
    func showError(_ error: String)
    func routeNext(_ isStudent: Bool)
}

protocol CodeEnteringPresenterProtocol {
    func textFieldFilled(withStringCode stringCode: String)
}
