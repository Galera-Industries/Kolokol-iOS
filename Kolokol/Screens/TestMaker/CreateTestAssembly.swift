//
//  TestMakerAssembly.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

enum CreateTestAssembly {
    static func build(test: TestModel? = nil) -> UIViewController {
        let keychain = KeychainManager()
        let vc = CreateTestViewController(test: test)
        let model = CreateTestModel(keychain)
        let presenter = CreateTestPresenter(view: vc, model: model, initial: test)
        vc.presenter = presenter
        return vc
    }
}
