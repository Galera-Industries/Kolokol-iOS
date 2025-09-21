//
//  AuthorizationAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

import UIKit

enum AuthorizationAssembly {
    static func build() -> UIViewController {
        let view = AuthorizationViewController()
        let model = AuthorizationModel()
        let keychain = KeychainManager()
        let presenter = AuthorizationPresenter(view: view, model: model, keychain: keychain)
        view.presenter = presenter
        return view
    }
}
