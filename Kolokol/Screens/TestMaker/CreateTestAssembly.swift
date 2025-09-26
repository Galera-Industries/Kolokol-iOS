//
//  TestMakerAssembly.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

enum CreateTestAssembly {
    static func build(testId: UUID? = nil) -> UIViewController {
        let keychain = KeychainManager()
        let vc = CreateTestViewController(testID: testId)
        let model = CreateTestModel(keychain)
        let presenter = CreateTestPresenter(view: vc, model: model, initialID: testId)
        vc.presenter = presenter
        return vc
    }
}
