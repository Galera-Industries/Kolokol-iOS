//
//  TestModel.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class TeacherStudentGradingViewModel: TeacherStudentGradingViewModelProtocol {

    var keychain: KeychainManagerProtocol
    
    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }
    
    func fetchGradingData() async throws -> SomeAnswer {
        try await Task.sleep(nanoseconds: 3_000_000_000)

        return
            SomeAnswer(
                name: "Arsenii",
                questions: [
                    "В чем отличие стека от кучи?"
                ],
                answer: [
                    "Отличий много, разумеется"
                ]
            )
    }

    func sendReview() async throws {
        
    }
}

