//
//  ReviewModel.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import Foundation

struct ReviewRequest: Codable {
    let items: [ReviewDetail]
}

struct ReviewDetail: Codable {
    let questionId: UUID
    let points: Int
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case points
        case comment
    }
}
