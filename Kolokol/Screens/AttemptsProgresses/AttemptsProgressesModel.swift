//
//  AttemptsProgresses.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import Foundation

final class AttemptsProgressesModel : AttemptsProgressesModelProtocol {
    private var keychain: KeychainManagerProtocol
    
    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }
    
    private func authHeaders() -> [String: String] {
        guard let token = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            return [:]
        }
        return [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
    }
    
    func getAttemptsRequest() async throws -> EmptyResponse {
//        let response: EmptyResponse = try await NetworkService.shared.request(
//            endpoint: "",
//            method: .
//        )
        return EmptyResponse()
    }
    
    func publishResultsRequest(_ request: PublishResultsRequest) async throws -> EmptyResponse {
        return EmptyResponse()
    }
}
