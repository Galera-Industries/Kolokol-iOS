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
    
    init(view: AuthorizationViewProtocol, model: AuthorizationModelProtocol) {
        self.view = view
        self.model = model
    }
    
    func sendEmailButtonPressed(withEmail email: String) {
        Task {
            do {
                let otpRequest = OtpRequest(email: email)
                let data = try await model.sendOtpRequest(otpRequest)
                
                await MainActor.run {
                    view?.routeNext()
                }
                
            } catch {
                let mappedError = mapError(error)
                view?.showError(mappedError)
            }
        }
    }
    
    private func mapError(_ error: Error) -> String {
        return ""
    }
}
