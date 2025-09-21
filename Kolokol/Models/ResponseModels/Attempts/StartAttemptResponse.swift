//
//  StartAttemptResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

// POST /attempts/start-by-code
struct StartAttemptResponse : Codable {
    let attemptId: UUID
    let testId: UUID
    let title: String
    let ttl: Int
    
    enum CodingKeys: String, CodingKey {
        case attemptId = "attempt_id"
        case testId = "test_id"
        case ttl = "time_limit_sec"
        case title
    }
}
