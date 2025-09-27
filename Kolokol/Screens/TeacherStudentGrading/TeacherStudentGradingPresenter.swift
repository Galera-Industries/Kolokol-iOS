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

    init(view: TeacherStudentGradingViewProtocol, model: TeacherStudentGradingViewModelProtocol, keychain: KeychainManagerProtocol) {
        self.view = view
        self.model = model
        self.keychain = keychain
    }

    func viewDidLoad() {
        Task {
            await MainActor.run { self.view?.setLoading(true) }
            do {
                let data = try await model.fetchGradingData()
                await MainActor.run {
                    self.view?.showStudentName(data.name)
                    self.view?.showQuestions(data.questions)
                    self.view?.showAnswers(data.answer)
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

    func sendReview() {
        Task {
            await MainActor.run { self.view?.setLoading(true) }

            try? await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                self.view?.setLoading(false)
                // тут потом роут на следующий экран
            }
        }
    }
}

