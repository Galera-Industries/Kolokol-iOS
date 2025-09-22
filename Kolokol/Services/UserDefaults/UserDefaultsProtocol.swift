//
//  UserDefaultsProtocol.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

protocol UserDefaultsProtocol {
    func saveCredentials(_ credentials: Credentials)
    func loadCredentials() -> Credentials
}
