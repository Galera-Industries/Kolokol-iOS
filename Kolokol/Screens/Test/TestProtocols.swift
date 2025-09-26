//
//  TestProtocols.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

protocol TestViewModelProtocol {
    func answer(answer: AnswerRequest) async throws -> AnswerResponse
    func submit() async throws -> EmptyResponse
}

protocol TestViewProtocol: AnyObject {
    func showQuestions(_ questions: [StudentQuestion])
    func showError(_ error: String)
    func showWaitingRoom()
    func hideWaitingRoom()
}

protocol TestPresenterProtocol {
    func configure(isStarted: Bool, code: String?, preloadedQuestions: [StudentQuestion]?)
    func answer(_ questionId: UUID, _ answer: String)
    func submit()
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
