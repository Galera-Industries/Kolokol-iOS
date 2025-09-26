//
//  TestMakerModel.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

final class CreateTestModel: CreateTestModelProtocol {
    var keychain: KeychainManagerProtocol
    
    init(_ keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }
    
    private func authHeaders() -> [String: String] {
        guard let token = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else {
            return [:]
        }
        return [
            "Authorization": "Bearer \(token)"
        ]
    }
    
    func create(_ request: CreateTestRequest) async throws -> CreateTestResponse {
        let endpoint = Endpoints.test.rawValue
        let resp: CreateTestResponse = try await NetworkService.shared.request(
            endpoint: endpoint,
            method: .post,
            body: request,
            headers: authHeaders()
        )
        return resp
    }
    
    func fetchEdit(id: UUID) async throws -> EditTestResponse {
        let endpoint = Endpoints.test.rawValue + "/\(id.uuidString)/edit"
        let resp: EditTestResponse = try await NetworkService.shared.request(
            endpoint: endpoint,
            method: .get,
            body: Optional<String>.none,
            headers: authHeaders()
        )
        return resp
    }

    func update(id: UUID, _ request: CreateTestRequest) async throws -> EmptyResponse {
        let endpoint = Endpoints.test.rawValue + "/\(id.uuidString)"
        let resp: EmptyResponse = try await NetworkService.shared.request(
            endpoint: endpoint,
            method: .put,
            body: request,
            headers: authHeaders()
        )
        return resp
    }

    func stop(id: UUID) async throws -> EmptyResponse {
        let endpoint = Endpoints.test.rawValue + "/\(id.uuidString)/stop"
        let resp: EmptyResponse = try await NetworkService.shared.request(
            endpoint: endpoint,
            method: .post,
            body: Optional<String>.none,
            headers: authHeaders()
        )
        return resp
    }
    
    func fetchStudents() async throws -> GetStudentsResponse {
        let endpoint = Endpoints.getStudent.rawValue
        let resp: GetStudentsResponse = try await NetworkService.shared.request(
            endpoint: endpoint,
            method: .get,
            body: Optional<String>.none,
            headers: authHeaders()
        )
        
        return resp
    }
}
