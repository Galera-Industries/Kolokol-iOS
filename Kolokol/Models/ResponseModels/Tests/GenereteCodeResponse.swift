//
//  GenereteCodeResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import Foundation

struct GenereteCodeResponse : Codable {
    let code: Int
    
    enum CodingKeys: String, CodingKey {
        case code = "code6"
    }
}
