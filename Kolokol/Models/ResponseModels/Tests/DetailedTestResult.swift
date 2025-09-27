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
    let maxPoints: Int
    let gotPoints: Int
    let type: QuestionType
    let text: String
    let imageURL: URL?
    let comment: String?
    let studentAnswer: StudentAnswer?
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case order
        case maxPoints = "max_points"
        case gotPoints = "got_points"
        case type
        case text
        case imageURL = "image_url"
        case comment
        case studentAnswer = "student_answer"
    }
}

struct StudentAnswer: Codable {
    let valueText: String?
    let selected: Int?
    let selectedList: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case valueText = "value_text"
        case selected
        case selectedList = "selected_list"
    }
    
    
}
