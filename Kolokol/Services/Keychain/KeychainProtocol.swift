//
//  KeychainProtocol.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

protocol KeychainManagerProtocol {
    func save(key: String, value: UUID) -> Bool
    func save(key: String, value: String) -> Bool
    func getUUID(key: String) -> UUID?
    func getString(key: String) -> String?
    func delete(key: String) -> Bool
}
