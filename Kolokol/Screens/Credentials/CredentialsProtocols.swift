//
//  CredentialProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

protocol CredentialsModelProtocol {
    @discardableResult
    func saveCredentials(_ name: String, _ userName: String, _ tgshka: String) -> Bool
}

protocol CredentialsPresenterProtocol {
    func saveButtonPressed(_ name: String, _ userName: String, _ tgshka: String)
}
