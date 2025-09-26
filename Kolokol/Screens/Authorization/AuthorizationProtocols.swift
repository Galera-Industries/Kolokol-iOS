//
//  AuthorizationProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

protocol AuthorizationModelProtocol {
    func sendOtpRequest(_ request: OTPRequest) async throws -> OTPResponse
}

protocol AuthorizationViewProtocol: AnyObject {
    func showError(_ error: String)
    func routeNext()
}

protocol AuthorizationPresenterProtocol {
    func sendEmailButtonPressed(withEmail email: String)
}
