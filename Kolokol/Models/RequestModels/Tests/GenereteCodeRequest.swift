//
//  GenereteCodeRequest.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import Foundation

struct GenereteCodeRequest : Codable {
    let testId: UUID
    
    enum CodingKeys: String, CodingKey {
        case testId = "test_id"
    }
}
