//
//  DetailedTestResultModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import Foundation

final class DetailedTestResultModel: DetailedTestResultModelProtocol {
    
    var keychain: KeychainManagerProtocol
    var userDefaults: UserDefaultsProtocol
    
    init(keychain: KeychainManagerProtocol, userDefaults: UserDefaultsProtocol) {
        self.keychain = keychain
        self.userDefaults = userDefaults
    }
    
    func fetchDetailedResults(_ testID: UUID) async throws -> DetailedTestResult {
        
        guard let accessToken = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            throw NetworkError(message: "No access token in keychain") ?? .decodingError
        }
        
        let response: DetailedTestResult = try await NetworkService.shared.request(endpoint: Endpoints.testsResults.rawValue + "/\(testID)/results" , method: .get, body: nil as EmptyBody?, headers: ["Authorization": "Bearer \(accessToken)"])
        
        return response
    }
    
    func loadCredentials() -> Credentials {
        return userDefaults.loadCredentials()
    }
}
