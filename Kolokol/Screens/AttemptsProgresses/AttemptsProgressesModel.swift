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
//        let item = GetAttemptsResponse.Item(
//            aiCheckStatus: .in_progress,
//            answered: 2,
//            attemptId: UUID(uuidString: "758702ec-6b85-47a5-91bb-d17f03f53db9")!,
//            firstName: "Влад",
//            lastName: "Панк",
//            result: 12,
//            tg: "@sundayti",
//            total: 7,
//            uid: "qYf56sPQukSEaeTZFfaCQHUfdxy2"
//        )
//    let response = GetAttemptsResponse(items: [item], stopped: false)
    let response: GetAttemptsResponse = try await NetworkService.shared.request(
        endpoint: Endpoints.test.rawValue + "/" + testId.uuidString + "/progress",
        method: .get,
        body: Optional<String>.none,
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
