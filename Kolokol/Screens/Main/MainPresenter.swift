//
//  MainPresenter.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    var model: MainModelProtocol
    var keychain: KeychainManagerProtocol

    init(view: MainViewProtocol, model: MainModelProtocol, keychain: KeychainManagerProtocol) {
        self.view = view
        self.model = model
        self.keychain = keychain
    }
}
