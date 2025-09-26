//
//  AnswerModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 26.09.2025.
//

import Foundation

struct AnswerRequest: Codable {
    let questionId: UUID
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case text
    }
}

struct AnswerResponse: Codable {
    let status: String
}
