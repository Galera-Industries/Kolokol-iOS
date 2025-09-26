//
//  UserDefaultsManager.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

final class UserDefaultsManager: UserDefaultsProtocol {
    private let nameKey = "nameKey"
    private let usernameKey = "usernameKey"
    private let tgKey = "tgKey"
    
    func saveCredentials(_ credentials: Credentials) {
        saveName(credentials.name)
        saveUsername(credentials.lastname)
        saveTg(credentials.tg)
    }
    
    func loadCredentials() -> Credentials {
        guard let name = UserDefaults.standard.string(forKey: nameKey),
              let username = UserDefaults.standard.string(forKey: usernameKey),
              let tg = UserDefaults.standard.string(forKey: tgKey) else {
            return Credentials(name: "Defaults", lastname: "Default", tg: "@mmrdrrr")}
        return Credentials(name: name, lastname: username, tg: tg)
    }
    
    
    private func saveName(_ name: String)  {
        UserDefaults.standard.set(name, forKey: nameKey)
    }
    
    private func saveUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: usernameKey)
    }
    
    private func saveTg(_ tg: String) {
        UserDefaults.standard.set(tg, forKey: tgKey)
    }
    
}
