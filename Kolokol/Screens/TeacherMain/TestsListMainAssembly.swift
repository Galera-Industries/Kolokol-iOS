//
//  TeacherMainAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import UIKit

enum TestsListMainAssembly {
    static func build(role: String) -> UIViewController {
        let view = TestsListMainViewController()
        let keychain = KeychainManager()
        let userDefaults = UserDefaultsManager()
        let model = TestsListMainModel(keychain: keychain, userDefaults: userDefaults)
        let presenter = TestsListMainPresenter(view: view, model: model, role: role)
        view.presenter = presenter
        return view
    }
}
