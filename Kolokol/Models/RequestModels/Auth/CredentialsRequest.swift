//
//  CredentialsRequest.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 26.09.2025.
//

import Foundation

struct CredentialsRequest: Codable {
    let telegram: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case telegram
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
