//
//  StartTestReponse.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 26.09.2025.
//

import Foundation

struct TestEnvelope: Codable {
    let test: StartTestResponse
}

struct StartTestResponse: Codable {
    let id: String
    let title: String
    let code6: String
    let answersVisible: Bool
    let resultsPublished: Bool
    let scoringMode: ScoringMode
    let timeLimitSec: Int
    let deadlineAt: Date?
    let questions: [StudentQuestion]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case code6
        case answersVisible = "answers_visible"
        case resultsPublished = "results_published"
        case scoringMode = "scoring_mode"
        case timeLimitSec = "time_limit_sec"
        case deadlineAt = "deadline_at"
        case questions
    }
}


struct StudentQuestion: Codable {
    let id: String
    let order: Int
    let text: String
    let type: QuestionType
    let weight: Int
    let isAnswered: Bool
    let options: [String: String]?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case text
        case type
        case weight
        case isAnswered = "is_answered"
        case options
        case imageURL = "image_url"
    }
}
