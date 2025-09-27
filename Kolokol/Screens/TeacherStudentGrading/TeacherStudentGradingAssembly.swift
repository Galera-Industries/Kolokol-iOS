//
//  TestAssembly.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

enum TeacherStudentGradingAssembly {
    static func build() -> UIViewController {
        let view = TeacherStudentGradingViewController()
        let keychain = KeychainManager()
        let model = TeacherStudentGradingViewModel(keychain: keychain)
        let presenter = TeacherStudentGradingPresenter(view: view, model: model, keychain: keychain)
        view.presenter = presenter
        return view
    }
}
