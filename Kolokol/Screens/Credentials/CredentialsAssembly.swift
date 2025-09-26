//
//  CredentialAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import UIKit

enum CredentialsAssembly {
    static func build() -> UIViewController {
        let view = CredentialsViewController()
        let userDefaults = UserDefaultsManager()
        let keychain = KeychainManager()
        let model = CredentialsModel(userDefaults: userDefaults, keychain: keychain)
        let presenter = CredentialsPresenter(view: view, model: model)
        view.presenter = presenter
        return view
    }
}
