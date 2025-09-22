//
//  CredentialModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

final class CredentialsModel: CredentialsModelProtocol {
    @discardableResult
    func saveCredentials(_ name: String, _ userName: String, _ tgshka: String) -> Bool {
        // saving in user defaults
        return true
    }
}
