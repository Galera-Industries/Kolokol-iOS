//
//  AuthorizationAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

import UIKit

enum AuthorizationAssembly {
    static func build() -> UIViewController {
        let view = AuthorizationView()
        let model = AuthorizationModel()
        let presenter = AuthorizationPresenter(view: view, model: model)
        view.presenter = presenter
        return view
    }
}
