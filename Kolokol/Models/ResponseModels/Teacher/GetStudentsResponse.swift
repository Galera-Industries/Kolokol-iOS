//
//  GetStudentsResponse.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import Foundation

struct GetStudentsResponse : Codable {
    struct Student : Codable {
        let id: String
        let email: String
        let tg: String
        let firstName: String
        let lastName: String
        
        enum CodingKeys: String, CodingKey {
            case id = "UID"
            case email = "Email"
            case tg = "Telegram"
            case firstName = "FirstName"
            case lastName = "LastName"
        }
    }
    
    let students: [Student]
}
