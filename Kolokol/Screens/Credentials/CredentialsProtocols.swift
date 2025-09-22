//
//  CredentialProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

protocol CredentialsModelProtocol {
    func saveCredentials(_ credentials: Credentials)
}

protocol CredentialsPresenterProtocol {
    func saveButtonPressed(_ name: String, _ userName: String, _ tgshka: String)
}
