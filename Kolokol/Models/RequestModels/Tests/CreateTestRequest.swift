//
//  CreateTestRequest.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

struct CreateTestRequest : Codable {
    struct Question: Codable {
        let type: QuestionType
        let text: String
        let imageUrl: URL?
        let order: Int
        let options: Options?
        enum CodingKeys: String, CodingKey {
            case type
            case text
            case imageUrl = "image_url"
            case order
            case options
        }
    }
    
    let title: String
    let published: Bool
    let deadlineAt: Date?
    let ttl: Int?
    let scoringMode: ScoringMode
    let resultsPublished: Bool
    let answersVisible: Bool
    let questions: [Question]
    let testId: UUID?
    let assignees: [String]
    let assignedMode: AssignedMode
    
    enum CodingKeys: String, CodingKey {
        case title
        case published
        case deadlineAt = "deadline_at"
        case ttl = "time_limit_sec"
        case scoringMode = "scoring_mode"
        case resultsPublished = "results_published"
        case answersVisible = "answers_visible"
        case questions
        case testId
        case assignees
        case assignedMode = "assigned_mode"
    }
}

struct EditTestResponse : Codable {
    struct QuestionDTO: Codable {
        let type: QuestionType
        let text: String
        let options: Options?
        let imageUrl: URL?
        let order: Int
        let weight: Int

        enum CodingKeys: String, CodingKey {
            case type, text, options, order, weight
            case imageUrl = "image_url"
        }
    }
    
    let title: String
    let published: Bool
    let deadlineAt: Date?
    let timeLimitSec: Int?
    let scoringMode: ScoringMode
    let resultsPublished: Bool
    let answersVisible: Bool
    let questions: [QuestionDTO]
    let assignees: [String]
    let assignedMode: AssignedMode
    

    enum CodingKeys: String, CodingKey {
        case title, published, questions, assignees
        case deadlineAt = "deadline_at"
        case timeLimitSec = "time_limit_sec"
        case scoringMode = "scoring_mode"
        case resultsPublished = "results_published"
        case answersVisible = "answers_visible"
        case assignedMode = "assigned_mode"
    }
}
enum AssignedMode : String, Codable {
    case all
    case selected
}
enum ScoringMode : String, Codable {
    case equal
    case weighted
}


struct Options : Codable {
    let choices: [Choice]?
    let correctIDs: [Int]?
    let correctText: String?

    enum CodingKeys: String, CodingKey {
        case choices
        case correctIDs = "correct_ids"
        case correctText = "correct_text"
    }
}

