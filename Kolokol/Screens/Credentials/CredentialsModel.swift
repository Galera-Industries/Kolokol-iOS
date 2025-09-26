//
//  CredentialModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import Foundation

final class CredentialsModel: CredentialsModelProtocol {
    var userDefaults: UserDefaultsProtocol
    var keychain: KeychainManagerProtocol
    
    init(userDefaults: UserDefaultsProtocol, keychain: KeychainManagerProtocol) {
        self.userDefaults = userDefaults
        self.keychain = keychain
    }
    
    func saveCredentials(_ credentials: Credentials) async throws -> CredentialsResponse {
        let request = CredentialsRequest(telegram: credentials.tg, firstName: credentials.name, lastName: credentials.lastname)
        
        guard let accessToken = keychain.getUUID(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? NetworkError.decodingError
        }
        
        let response: CredentialsResponse = try await NetworkService.shared.request(
            endpoint: Endpoints.credentials.rawValue,
            method: .post,
            body: request as CredentialsRequest,
            headers: ["Authorization": "Bearer \(accessToken.uuidString)"]
        )
        
        userDefaults.saveCredentials(credentials)
        debugPrint("Saved: \n\(credentials.name)\n\(credentials.lastname)\n\(credentials.tg)\n In UserDefaults")
        
        return response
    }
}
