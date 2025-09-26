//
//  MainModel.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class MainModel: MainModelProtocol {
    
    var keychain: KeychainManagerProtocol
    
    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }
    
    func startTest(code: String) async throws -> TestEnvelope {
        let request = StartRequest(code: code)
        
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? .decodingError
        }
        
        let response: TestEnvelope = try await NetworkService.shared.request(endpoint: Endpoints.startTest.rawValue, method: .post, body: request as StartRequest, headers: ["Authorization": "Bearer \(accessToken)"])
        
        return response
    }
}
