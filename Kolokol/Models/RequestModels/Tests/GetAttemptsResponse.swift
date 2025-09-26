//
//  GetAttemptsResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import Foundation

struct GetAttemptsResponse: Codable {
    struct Item : Codable {
        let assessed: String
        let answered: Int
        let attemptId: UUID
        let firstName: String
        let lastName: String
        let result: Int
        let tg: String
        let total: Int
        let uid: String
        
        enum CodingKeys: String, CodingKey {
            case assessed = "ai_check_status"
            case answered
            case attemptId = "attempt_id"
            case firstName = "first_name"
            case lastName = "last_name"
            case result
            case tg = "telegram"
            case total
            case uid = "user_id"
        }
    }
    let items: [Item]
    let stopped: Bool
}
