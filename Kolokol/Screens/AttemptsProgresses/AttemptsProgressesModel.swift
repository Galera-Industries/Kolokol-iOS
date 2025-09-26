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
    
    func getAttemptsRequest(_ testId: UUID) async throws -> GetAttemptsResponse {
        let response: GetAttemptsResponse = try await NetworkService.shared.request(
            endpoint: Endpoints.test.rawValue + "/" + testId.uuidString + "/progress",
            method: .get,
            body: EmptyBody(),
            headers: authHeaders()
        )
        return response
    }
    
    func publishResultsRequest(_ request: PublishResultsRequest, testId: UUID) async throws -> EmptyResponse {
        let response: EmptyResponse = try await NetworkService.shared.request(
            endpoint: Endpoints.test.rawValue + "/" + testId.uuidString + "/publish-results",
            method: .post,
            body: request,
            headers: authHeaders()
        )
        return response
    }
}
