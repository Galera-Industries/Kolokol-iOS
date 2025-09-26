//
//  GetTestsResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

// GET /teacher/tests
struct TestModel: Codable {
    var id: String
    let code6: String
    let title: String
    let published: Bool
    let resultsPublished: Bool
    let answersVisible: Bool
    let isStopped: Bool
    let publishedAt: Date?
    let deadlineAt: Date?
    let participants: Int
    let questions: Int
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case code6
        case title
        case published
        case resultsPublished = "results_published"
        case answersVisible = "answers_visible"
        case isStopped = "is_stopped"
        case publishedAt = "published_at"
        case deadlineAt = "deadline_at"
        case participants
        case questions
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
