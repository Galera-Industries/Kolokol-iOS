//
//  TestProtocols.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

protocol TestViewModelProtocol {
    func pollStart(code: String) async throws -> [Question]?
    func fetchTasks(code: String) async throws -> [Question]
}

protocol TestViewProtocol: AnyObject {
    func showQuestions(_ questions: [Question])
    func showError(_ error: String)
    func showWaitingRoom()
    func hideWaitingRoom()
}

protocol TestPresenterProtocol {
    func configure(isStarted: Bool, code: String?, preloadedQuestions: [Question]?)
    func viewDidLoad()
}

// MARK: - TEMPORARY
struct TestResponse: Decodable {
    let test: Test
}
struct Test: Decodable {
    let questions: [Question]
}
struct Question: Decodable {
    let id: String
    let type: String
    let text: String
    let order: Int
}
