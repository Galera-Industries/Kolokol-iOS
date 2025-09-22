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
        let model = CredentialsModel(userDefaults: userDefaults)
        let presenter = CredentialsPresenter(view: view, model: model)
        view.presenter = presenter
        return view
    }
}
