//
//  CreateTestResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 20.09.2025.
//

import Foundation

// POST /tests
struct CreateTestResponse: Codable {
    let id: UUID
    let code: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case code = "code6"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        
        if let intCode = try? container.decode(Int.self, forKey: .code) {
            code = intCode
        } else {
            let strCode = try container.decode(String.self, forKey: .code)
            guard let intCode = Int(strCode) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .code,
                    in: container,
                    debugDescription: "code6 is not Int-compatible"
                )
            }
            code = intCode
        }
    }
}
