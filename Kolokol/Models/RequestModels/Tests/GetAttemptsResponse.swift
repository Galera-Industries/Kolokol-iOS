//
//  GetAttemptsResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import Foundation

struct GetAttemptsResponse: Codable {
    struct Item: Codable {
        let aiCheckStatus: AICheckStatus
        let answered: Int
        let attemptId: UUID
        let firstName: String
        let lastName: String
        let result: Int?
        let tg: String?
        let total: Int
        let uid: String

        enum CodingKeys: String, CodingKey {
            case aiCheckStatus = "ai_check_status"
            case answered
            case attemptId = "attempt_id"
            case firstName = "first_name"
            case lastName = "last_name"
            case result
            case tg = "telegram"
            case total
            case uid = "user_id"
        }

//        init(from decoder: Decoder) throws {
//            let c = try decoder.container(keyedBy: CodingKeys.self)
//
//            // обязательные и точно не-null
//            self.answered  = try c.decode(Int.self,    forKey: .answered)
//            self.attemptId = try c.decode(UUID.self,   forKey: .attemptId)
//            self.firstName = (try? c.decode(String.self, forKey: .firstName)) ?? ""
//            self.lastName  = (try? c.decode(String.self, forKey: .lastName))  ?? ""
//            self.total     = try c.decode(Int.self,     forKey: .total)
//            self.uid       = try c.decode(String.self,  forKey: .uid)
//
//            // «хрупкие» поля с фолбэками
//            self.aiCheckStatus = (try? c.decode(AICheckStatus.self, forKey: .aiCheckStatus)) ?? .none
//            self.result        = try? c.decodeIfPresent(Int.self, forKey: .result)
//            self.tg            = try? c.decodeIfPresent(String.self, forKey: .tg)
//        }
    }

    let items: [Item]
    let stopped: Bool
}
