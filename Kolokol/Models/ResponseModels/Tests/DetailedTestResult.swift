//
//  DetailedTestResult.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import Foundation

struct DetailedTestResult: Codable {
    let attemptId: UUID
    let testId: UUID
    let title: String
    let answersVisible: Bool
    let items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case attemptId = "attempt_id"
        case testId = "test_id"
        case title
        case answersVisible = "answers_visible"
        case items
    }
}

struct Item: Codable {
    let questionId: UUID
    let order: Int
    let comment: String
    let answer: String
    let maxPoints: Int
    let gotPoints: Int
    let type: QuestionType
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case order
        case comment
        case answer
        case maxPoints = "max_points"
        case gotPoints = "got_points"
        case type
    }
}
