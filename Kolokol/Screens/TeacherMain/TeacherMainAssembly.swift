//
//  TeacherMainAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import UIKit

enum TeacherMainAssembly {
    static func build() -> UIViewController {
        let view = TeacherMainViewController()
        let keychain = KeychainManager()
        let model = TeacherMainModel(keychain: keychain)
        let presenter = TeacherMainPresenter(view: view, model: model)
        view.presenter = presenter
        return view
    }
}
