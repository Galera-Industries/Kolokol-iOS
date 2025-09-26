//
//  GetTestsResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

// GET /teacher/tests
struct TestModel : Codable {
    let id: UUID
    let code: Int
    let title: String
    let published: Bool
    let resultsPublished: Bool
    let answersVisible: Bool
    let isStopped: Bool
    let deadlineAt: Date
    let participans: Int
    let questions: Int
    let createdAt: Date
    let updatedAt: Date
    let publishedAt: Date
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case code = "code6"
        case title
        case published
        case resultsPublished = "results_published"
        case answersVisible = "answers_visible"
        case isStopped = "is_stopped"
        case deadlineAt = "deadline_at"
        case participans
        case questions
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
    }
}
