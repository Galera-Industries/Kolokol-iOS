//
//  CodeEnteringAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import UIKit

enum CodeEnteringAssembly {
    static func build() -> UIViewController {
        let view = CodeEnteringViewController()
        let userDefaults = UserDefaultsManager()
        let model = CodeEnteringModel(userDefaults: userDefaults)
        let keychain = KeychainManager()
        let presenter = CodeEnteringPresenter(view: view, model: model, keychain: keychain)
        view.presenter = presenter
        return view
    }
}
