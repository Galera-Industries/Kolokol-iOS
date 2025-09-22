//
//  CredentialModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

final class CredentialsModel: CredentialsModelProtocol {
    var userDefaults: UserDefaultsProtocol
    
    init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
    }
    
    func saveCredentials(_ credentials: Credentials) {
        userDefaults.saveCredentials(credentials)
    }
}
