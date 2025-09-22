//
//  AttemptsProgressesAssembly.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import UIKit

/// пока непонятно как тест айди хранить
enum AttemptsProgressesAssembly {
    @MainActor static func build(withTestID testID: UUID) -> UIViewController {
        let view = AttemptsProgressesVC()
        let keychain = KeychainManager()
        let presenter = AttemptsProgressesPresenter(view: view, testId: testID, keychain: keychain)
        view.presenter = presenter
        return view
    }
}
