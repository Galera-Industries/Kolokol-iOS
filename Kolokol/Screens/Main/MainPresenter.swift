//
//  MainPresenter.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    var model: MainModelProtocol
    var keychain: KeychainManagerProtocol
    var userDefaults: UserDefaultsProtocol

    init(view: MainViewProtocol, model: MainModelProtocol, keychain: KeychainManagerProtocol, userDefaults: UserDefaultsProtocol) {
        self.view = view
        self.model = model
        self.keychain = keychain
        self.userDefaults = userDefaults
    }
    
    func viewLoaded() {
        let credentials = userDefaults.loadCredentials()
        guard let email = keychain.getString(key: KeychainManager.keyForSaveEmail) else { return }
        view?.setCredentials(credentials, email)
    }
}
