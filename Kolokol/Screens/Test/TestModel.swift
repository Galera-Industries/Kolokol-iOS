//
//  TestModel.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class TestViewModel: TestViewModelProtocol {
    
    var keychain: KeychainManagerProtocol
    
    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }
    
    func answer(answer: AnswerRequest) async throws -> AnswerResponse {
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? .decodingError
        }
        
        let response: AnswerResponse = try await NetworkService.shared.request(endpoint: Endpoints.answer.rawValue, method: .post, body: answer as AnswerRequest, headers: ["Authorization": "Bearer \(accessToken)"])
        
        return response
    }
    
    func submit() async throws -> AnswerResponse {
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? .decodingError
        }
        
        let response: AnswerResponse = try await NetworkService.shared.request(endpoint: Endpoints.submit.rawValue, method: .post, body: nil as EmptyBody?, headers: ["Authorization": "Bearer \(accessToken)"])
        
        return response
    }
}

