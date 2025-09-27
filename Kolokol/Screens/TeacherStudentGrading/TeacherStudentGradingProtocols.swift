//
//  TestProtocols.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

protocol TeacherStudentGradingViewModelProtocol {
    func fetchGradingData() async throws -> SomeAnswer
    func sendReview() async throws -> Void
}

protocol TeacherStudentGradingViewProtocol: AnyObject {
    func showQuestions(_ questions: [String])
    func showAnswers(_ answers: [String])
    func showStudentName(_ name: String)
    func showError(_ error: String)
    func setLoading(_ active: Bool)
}

protocol TeacherStudentGradingPresenterProtocol {
    func viewDidLoad()
    func sendReview()
}

// MARK: - DELETE AFTER ADDING BACKEND LOGIC
struct SomeAnswer {
    var name: String
    var questions: [String]
    var answer: [String]
}
