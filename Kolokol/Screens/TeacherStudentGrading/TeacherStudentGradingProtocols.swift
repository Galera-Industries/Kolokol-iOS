//
//  TestProtocols.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

protocol TeacherStudentGradingViewModelProtocol {
    func fetchGradingData(testID: UUID) async throws -> DetailedTestResult
    func sendReview(testUI: UUID, _ request: ReviewRequest) async throws -> EmptyResponse
}

protocol TeacherStudentGradingViewProtocol: AnyObject {
    func showQuestions(_ questions: [Item])
    func showAnswers(_ answers: [String])
    func showStudentName(_ name: String)
    func showError(_ error: String)
    func setLoading(_ active: Bool)
}

protocol TeacherStudentGradingPresenterProtocol {
    func viewDidLoad()
    func sendReview(_ order: Int, _ points: Int, _ comment: String?)
}

// MARK: - DELETE AFTER ADDING BACKEND LOGIC
struct SomeAnswer {
    var name: String
    var questions: [String]
    var answer: [String]
}
