//
//  TestModel.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class TestViewModel: TestViewModelProtocol {
    private var pollAttempts: [String: Int] = [:]

    func pollStart(code: String) async throws -> [Question]? {
        try await Task.sleep(nanoseconds: 700_000_000)

        let attempts = (pollAttempts[code] ?? 0) + 1
        pollAttempts[code] = attempts

        guard attempts >= 3 else { return nil }

        return generateQuestions(count: 15)
    }

    func fetchTasks(code: String) async throws -> [Question] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return generateQuestions(count: 15)
    }

    // MARK: - Helpers
    private func generateQuestions(count: Int) -> [Question] {
        (0..<count).map { i in
            Question(
                id: UUID().uuidString,
                type: "text",
                text: "Вопрос \(i + 1): чем отличается стек от кучи?",
                order: i
            )
        }
    }
}

