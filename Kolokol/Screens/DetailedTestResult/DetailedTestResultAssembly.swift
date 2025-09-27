//
//  DetailedTestResultAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import UIKit

enum DetailedTestResultAssembly {
    static func build(isStudent: Bool, testResult: TestResult? = nil) -> UIViewController {
        let view = DetailedTestResultViewController()
        let keychain = KeychainManager()
        let userDefaults = UserDefaultsManager()
        let model = DetailedTestResultModel(keychain: keychain, userDefaults: userDefaults)
        let presenter = DetailedTestResultPresenter(view: view, model: model, isStudent: isStudent, testResult: testResult)
        view.presenter = presenter
        return view
    }
}
