//
//  TestPresenter.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

final class TestPresenter: TestPresenterProtocol {
    weak var view: TestViewProtocol?
    var model: TestViewModelProtocol
    var keychain: KeychainManagerProtocol

    private var isStartedFlag: Bool = false
    private var code: String?
    private var preloaded: [StudentQuestion]?

    private var pollingTask: Task<Void, Never>?

    init(view: TestViewProtocol, model: TestViewModelProtocol, keychain: KeychainManagerProtocol) {
        self.view = view
        self.model = model
        self.keychain = keychain
    }

    func configure(isStarted: Bool, code: String?, preloadedQuestions: [StudentQuestion]?) {
        self.isStartedFlag = isStarted
        self.code = code
        self.preloaded = preloadedQuestions
    }

    func viewDidLoad() {
        // Сценарий 1: уже есть тело - значит не ходим в бек и сразу показываем тест
        if isStartedFlag, let ready = preloaded, !ready.isEmpty {
            view?.showQuestions(ready)
            view?.hideWaitingRoom()
            return
        }

        // Сценарий 2: тест не начался — показываем комнату ожидания и шорт-поллим бек
        guard let code else {
            view?.showError("Не передан код теста")
            return
        }

        view?.showWaitingRoom()

        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            guard let self else { return }
            do {
                while !Task.isCancelled {
                    //let response = try await model.startTest(code: code)
//                    await MainActor.run {
//                        self.view?.showQuestions(response.test.questions)
//                        self.view?.hideWaitingRoom()
//
//                    }
                }
            } catch {
                await MainActor.run {
                    self.view?.showError("Не удалось проверить старт теста")
                }
            }
        }
    }
    
    func answer(_ questionId: UUID, _ answer: String) {
        Task {
            do {
                let request = AnswerRequest(questionId: questionId, text: answer)
                _ = try await model.answer(answer: request)
            } catch {
                
                await MainActor.run {
                    view?.showError("Не удалось ответить, повтори попытку позже")
                }
                
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func submit() {
        Task {
            do {
                _ = try await model.submit()
                view?.goBack()
            } catch {
                await MainActor.run {
                    view?.showError("Не удалось ответить, повтори попытку позже")
                }
                debugPrint(error.localizedDescription)
            }
        }
    }
    

    deinit {
        pollingTask?.cancel()
    }
}

