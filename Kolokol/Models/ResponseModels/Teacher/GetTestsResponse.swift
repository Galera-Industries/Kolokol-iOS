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
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case code = "code6"
        case title
        case published
        case resultsPublished = "results_published"
        case answersVisible = "answers_visible"
        case createdAt = "created_at"
    }
}
