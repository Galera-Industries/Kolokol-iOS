//
//  TestPresenter.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class TeacherStudentGradingPresenter: TeacherStudentGradingPresenterProtocol {
    weak var view: TeacherStudentGradingViewProtocol?
    var model: TeacherStudentGradingViewModelProtocol
    var keychain: KeychainManagerProtocol
    var testID: UUID

    init(view: TeacherStudentGradingViewProtocol, model: TeacherStudentGradingViewModelProtocol, keychain: KeychainManagerProtocol, testID: UUID) {
        self.view = view
        self.model = model
        self.keychain = keychain
        self.testID = testID
    }
    
    func viewDidLoad() {
        Task {
            await MainActor.run { self.view?.setLoading(true) }
            do {
                let data = try await model.fetchGradingData(testID: testID)
                await MainActor.run {
                    //self.view?.showStudentName(data.name)
                    self.view?.showQuestions(data.items)
                    var answers: [String] = []
                    for item in data.items {
                        if let answer = item.studentAnswer {
                            if let text = answer.valueText {
                                answers.append(text)
                            }
                        }
                    }
                    self.view?.showAnswers(answers)
                    self.view?.setLoading(false)
                }
            } catch {
                await MainActor.run {
                    self.view?.setLoading(false)
                    self.view?.showError("Не удалось загрузить данные")
                }
            }
        }
    }

    func sendReview(_ order: Int, _ points: Int, _ comment: String?) {
        Task {
            await MainActor.run { self.view?.setLoading(true) }
            let data = try await model.fetchGradingData(testID: testID)
            
            if let index = data.items.firstIndex(where: {$0.order == order}) {
                let questionId = data.items[index].questionId
                let request = ReviewRequest(items: [ReviewDetail(questionId: questionId, points: points, comment: comment)])
                _ = try await model.sendReview(testUI: testID, request)
                
            }
            await MainActor.run {
                self.view?.setLoading(false)
                // тут потом роут на следующий экран
            }
        }
    }
}

