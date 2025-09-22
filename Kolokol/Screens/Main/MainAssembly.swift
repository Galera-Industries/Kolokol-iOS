//
//  MainAssembly.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

enum MainAssembly {
    static func build() -> UIViewController {
        let view = MainViewController()
        let model = MainModel()
        let keychain = KeychainManager()
        let presenter = MainPresenter(view: view, model: model, keychain: keychain)
        view.presenter = presenter
        return view
    }
}
