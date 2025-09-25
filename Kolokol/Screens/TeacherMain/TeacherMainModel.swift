//
//  TeacherMainModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

final class TeacherMainModel: TeacherMainModelProtocol {
    
    var keychain: KeychainManagerProtocol
    
    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }
    
    func fetchTests() async throws -> [TestModel] {
        let response: [TestModel] = try await NetworkService.shared.request(endpoint: Endpoints.teacherTests.rawValue, method: .get, body: nil as EmptyBody?)
        return response
    }
}
