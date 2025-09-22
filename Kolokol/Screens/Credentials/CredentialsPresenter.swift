//
//  CredentialPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

final class CredentialsPresenter: CredentialsPresenterProtocol {    
    weak var view: CredentialsViewController?
    var model: CredentialsModelProtocol

    init(view: CredentialsViewController, model: CredentialsModelProtocol) {
        self.view = view
        self.model = model
    }
    
    func saveButtonPressed(_ name: String, _ userName: String, _ tgshka: String) {
        let credentials = Credentials(name: name, username: userName, tg: tgshka)
        model.saveCredentials(credentials)
    }
}
