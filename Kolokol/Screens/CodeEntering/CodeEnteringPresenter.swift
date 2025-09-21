//
//  CodeEnteringPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

final class CodeEnteringPresenter: CodeEnteringPresenterProtocol {
    weak var view: CodeEnteringViewProtocol?
    var model: CodeEnteringModelProtocol
    var keychain: KeychainManagerProtocol
    
    init(view: CodeEnteringViewProtocol, model: CodeEnteringModelProtocol, keychain: KeychainManagerProtocol) {
        self.view = view
        self.model = model
        self.keychain = keychain
    }
    
    func textFieldFilled(withStringCode stringCode: String) {
        Task {
            do {
                guard let email = keychain.getString(key: KeychainManager.keyForSaveEmail),
                      let regToken = keychain.getUUID(key: KeychainManager.keyForSaveRegToken),
                      let otp = Int(stringCode) else { return }
                
                let request = ConfirmOTPRequest(email: email, regToken: regToken, otp: otp)
                
                let data = try await model.sendOtpConfirmationRequest(request)
                
                _ = keychain.save(key: KeychainManager.keyForSaveAccessToken, value: data.accessToken)
                _ = keychain.save(key: KeychainManager.keyForSaveRefreshToken, value: data.refreshToken)
                
                await MainActor.run {
                    if let student = data.profileComplete {
                        view?.routeNext(student)
                    } else {
                        view?.routeNext(true)
                    }
                }
                
            } catch {
                let mappedError = mapError(error)
                
                await MainActor.run {
                    view?.showError(mappedError)
                }
            }
        }
    }
    
    func sendCodePressed() {
        Task {
            do {
                guard let email = keychain.getString(key: KeychainManager.keyForSaveEmail) else { return }
                let otpRequest = OTPRequest(email: email)
                let data = try await model.sendConfirmationCodeAgainRequest(otpRequest)
                _ = keychain.save(key: KeychainManager.keyForSaveRegToken, value: data.regToken)
                _ = keychain.save(key: KeychainManager.keyForSaveEmail, value: data.email)
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
