//
//  TestsResult.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import Foundation

struct TestsResult: Codable {
    let attemptId: UUID
    let testId: UUID
    let code6: String
    let title: String
    let startedAt: Date
    let submittedAt: Date
    let resultsPublished: Bool
    let scorePct: Int
    let grade10: Int
    
    enum CodingKeys: String, CodingKey {
        case attemptId = "attempt_id"
        case testId = "test_id"
        case code6
        case title
        case startedAt = "started_at"
        case submittedAt = "submitted_at"
        case resultsPublished = "results_published"
        case scorePct = "score_pct"
        case grade10
    }
}
