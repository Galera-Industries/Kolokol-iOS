//
//  MainProtocols.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

protocol MainModelProtocol {

}

protocol MainViewProtocol: AnyObject {
    func setCredentials(_ credentials: Credentials, _ email: String)
}

protocol MainPresenterProtocol {
    func viewLoaded()
    var keychain: KeychainManagerProtocol { get }
}
