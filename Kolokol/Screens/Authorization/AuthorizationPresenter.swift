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
        Task {
            do {
                let otpRequest = OTPRequest(email: email)
                let data = try await model.sendOtpRequest(otpRequest)
                _ = keychain.save(key: KeychainManager.keyForSaveRegToken, value: data.regToken)
                _ = keychain.save(key: KeychainManager.keyForSaveEmail, value: data.email)
                await MainActor.run {
                    view?.routeNext()
                }
                
            } catch {
                let mappedError = mapError(error)
                
                await MainActor.run {
                    view?.showError(mappedError)
                }
            }
        }
    }
    
    private func mapError(_ error: Error) -> String {
        guard let networkError = error as? NetworkError else { return "Unknown error" }
        switch networkError {
        case .noData:
            return "Bad input, try later"
        case .decodingError:
            return "Bad input, try later"
        case .internalServerError:
            return "Server error, please, try later"
        case .unknown(let message):
            if let message {
                return message
            } else {
                return "Server error, please, try later"
            }
        case .forbidden:
            return "You dont have access for this action"
        case .notFound:
            return "User with this email not found"
        case .invalidURL:
            return "Bad input, try later"
        case .invalidCode:
            return "Bad input, try later"
        }
    }
}
