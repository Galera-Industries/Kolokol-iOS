//
//  TestAssembly.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

enum TestAssembly {
    static func buildWaitingRoom(code: String) -> UIViewController {
        let view = TestViewController()
        let keychain = KeychainManager()
        let model = TestViewModel(keychain: keychain)
        let presenter = TestPresenter(view: view, model: model, keychain: keychain)
        presenter.configure(isStarted: false, code: code, preloadedQuestions: nil)
        view.presenter = presenter
        return view
    }

    static func buildStarted(preloadedQuestions: [StudentQuestion]) -> UIViewController {
        let view = TestViewController()
        let keychain = KeychainManager()
        let model = TestViewModel(keychain: keychain)
        let presenter = TestPresenter(view: view, model: model, keychain: keychain)
        presenter.configure(isStarted: true, code: nil, preloadedQuestions: preloadedQuestions)
        view.presenter = presenter
        return view
    }
}
