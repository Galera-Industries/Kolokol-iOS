//
//  AuthorizationPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

import Foundation

final class AuthorizationPresenter: AuthorizationPresenterProtocol {
    weak var view: AuthorizationViewProtocol?
    var model: AuthorizationModelProtocol
    var keychain: KeychainManagerProtocol

    init(view: AuthorizationViewProtocol, model: AuthorizationModelProtocol, keychain: KeychainManagerProtocol) {
        self.view = view
        self.model = model
        self.keychain = keychain
    }
    
    func sendEmailButtonPressed(withEmail email: String) {
        view?.routeNext()
        Task {
            do {
                let otpRequest = OTPRequest(email: email)
                let data = try await model.sendOtpRequest(otpRequest)
                _ = keychain.save(key: KeychainManager.keyForSaveRegToken, value: data.regToken)
                _ = keychain.save(key: KeychainManager.keyForSaveEmail, value: data.email)
                
            } catch {
                guard let error = error as? NetworkError else { return }
                debugPrint(error.localizedDescription)
            }
        }
    }
}
