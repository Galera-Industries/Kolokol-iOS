//
//  SearchTestResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

// GET /tests/search
struct SearchTestResponse : Codable {
    struct QuestionModel: Codable {
        let id: String
        let type: QuestionType
        let text: String
        let imageUrl: URL?
        let order: Int
        let weight: Int
        let choices: [Choice]?
        
        enum CodingKeys: String, CodingKey {
            case id, type, text, order, weight, choices
            case imageUrl = "image_url"
        }
    }
    
    let title: String
    let deadlineAt: Date
    let ttl: Int // В секнуднах
    let questions: [QuestionModel]
    
    enum CodingKeys: String, CodingKey {
        case title, questions
        case deadlineAt = "deadline_at"
        case ttl = "time_limit_sec"
    }
}



struct Choice : Codable {
    let id: Int
    let text: String
}

enum QuestionType: String, Codable {
    case text
    case multi
    case single
    case textKey = "text_key"
}
