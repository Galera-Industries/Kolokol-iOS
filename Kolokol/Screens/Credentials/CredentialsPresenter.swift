//
//  CredentialPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

final class CredentialsPresenter: CredentialsPresenterProtocol {    
    weak var view: CredentialsViewProtocol?
    var model: CredentialsModelProtocol

    init(view: CredentialsViewProtocol, model: CredentialsModelProtocol) {
        self.view = view
        self.model = model
    }
    
    func saveButtonPressed(_ name: String, _ userName: String, _ tgshka: String) {
        let credentials = Credentials(name: name, lastname: userName, tg: tgshka)
        Task {
            do {
                _ = try await model.saveCredentials(credentials)
                await MainActor.run {
                    view?.routeNext()
                }
            } catch {
                await MainActor.run {
                    view?.showError("Не получилось сохранить данные, попробуйте снова позже")
                }
            }
        }
        
    }
}
