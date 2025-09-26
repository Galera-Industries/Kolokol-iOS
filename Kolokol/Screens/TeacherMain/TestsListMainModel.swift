//
//  TeacherMainModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

final class TestsListMainModel: TeacherMainModelProtocol {
    
    var keychain: KeychainManagerProtocol
    var userDefaults: UserDefaultsProtocol
    
    init(keychain: KeychainManagerProtocol, userDefaults: UserDefaultsProtocol) {
        self.keychain = keychain
        self.userDefaults = userDefaults
    }
    
    func fetchTests() async throws -> [TestModel] {
        
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No accessToken in keychain") ?? NetworkError.decodingError
        }
        
        let response: [TestModel] = try await NetworkService.shared.request(endpoint: Endpoints.teacherTests.rawValue, method: .get, body: nil as EmptyBody?, headers: ["Authorization": "Bearer \(accessToken)"])

        return response
    }
    
    func fetchCredentials() -> (String, String) {
        guard let email = keychain.getString(key: KeychainManager.keyForSaveEmail) else { return ("ERROR","ERROR") }
        let name = userDefaults.loadCredentials().name
        return (email, name)
    }
    
    
    func fetchTestsResults() async throws -> [TestResult] {
        
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? .decodingError
        }
        
        let response: [TestResult] = try await NetworkService.shared.request(endpoint: Endpoints.testsResults.rawValue, method: .get, body: nil as EmptyBody?, headers: ["Authorization": "Bearer \(accessToken)"])
        
        return response
    }
}
