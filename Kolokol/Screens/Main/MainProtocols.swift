//
//  MainProtocols.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

protocol MainModelProtocol {
    func startTest(code: String) async throws -> TestEnvelope
}

protocol MainViewProtocol: AnyObject {
    func setCredentials(_ credentials: Credentials, _ email: String)
    func routeToTestScreen(_ questions: [StudentQuestion])
}

protocol MainPresenterProtocol {
    func viewLoaded()
    func startTest(withCode code: String)
    var keychain: KeychainManagerProtocol { get }
}
