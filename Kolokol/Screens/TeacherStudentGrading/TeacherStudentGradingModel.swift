//
//  TestModel.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class TeacherStudentGradingViewModel: TeacherStudentGradingViewModelProtocol {

    var keychain: KeychainManagerProtocol
    
    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }
    
    func fetchGradingData(testID: UUID) async throws -> DetailedTestResult {
        
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? .decodingError
        }
        
        let response: DetailedTestResult = try await NetworkService.shared.request(endpoint: Endpoints.attempts.rawValue + testID.uuidString + "/details", method: .get, body: nil as EmptyBody?, headers: ["Authorization": "Bearer \(accessToken)"])
        
        return response
    }
    
    
    func sendReview(testUI testID: UUID, _ request: ReviewRequest) async throws -> EmptyResponse {
     
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? .decodingError
        }
        
        let response: EmptyResponse = try await NetworkService.shared.request(endpoint: Endpoints.attempts.rawValue + testID.uuidString + "/grade/items", method: .post, body: request as ReviewRequest, headers: ["Authorization": "Bearer \(accessToken)"])
        
        return response
        
    }
    
    
}

