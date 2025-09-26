//
//  TestMakerPresenter.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

final class CreateTestPresenter: CreateTestPresenterProtocol {

    // MARK: - Deps
    private weak var view: CreateTestViewProtocol?
    private let model: CreateTestModelProtocol

    // MARK: - State
    private var current: TestModel?
    private var isPublished = false

    // MARK: - Init
    init(view: CreateTestViewProtocol, model: CreateTestModelProtocol, initial: TestModel?) {
        self.view = view
        self.model = model
        self.current = initial
    }

    // MARK: - Lifecycle
    func viewDidLoad() {
        guard let test = current,
              let id = UUID(uuidString: test.id) else { return }

        Task { @MainActor [weak self] in
            guard let self, let view = self.view else { return }
            view.setLoading(true)
            defer { view.setLoading(false) }

            do {
                let dto = try await model.fetchEdit(id: id)
                self.isPublished = dto.published
                view.fillFromEdit(dto)
            } catch {
                view.showAlert(title: "Ошибка", message: self.localized(error))
            }
        }
    }

    // MARK: - Actions
    func saveTapped(request: CreateTestRequest, publish: Bool) {
        if let err = validate(request: request) {
            Task { @MainActor [weak self] in
                self?.view?.showAlert(title: "Нужно исправить", message: err)
            }
            return
        }

        Task { @MainActor [weak self] in
            guard let self, let view = self.view else { return }
            view.setLoading(true)
            defer { view.setLoading(false) }

            if let id = current?.id {
                // PUT /tests/{id}
                do {
                    guard let uuid = UUID(uuidString: id),
                          let currentTest = current else { return }
                    let response = try await model.update(id: uuid, request)
                    if publish {
                        self.isPublished = true
                        view.setPublishedUI(true)
                        let test = TestModel(
                            id: currentTest.id,
                            code6: String(currentTest.code6),
                            title: request.title,
                            published: true,
                            resultsPublished: request.resultsPublished,
                            answersVisible: request.answersVisible,
                            isStopped: false,
                            publishedAt: Date(),
                            deadlineAt: request.deadlineAt,
                            participants: 0,
                            questions: request.questions.count,
                            createdAt: currentTest.createdAt,
                            updatedAt: Date()
                        )
                        NotificationCenter.default.post(name: .testUpdatedEvent, object: nil, userInfo: ["test": test])
                        view.showAlert(title: "Опубликовано", message: "Тест успешно опубликован.")
                    } else {
                        let test = TestModel(
                            id: currentTest.id,
                            code6: String(currentTest.code6),
                            title: request.title,
                            published: false,
                            resultsPublished: request.resultsPublished,
                            answersVisible: request.answersVisible,
                            isStopped: false,
                            publishedAt: nil,
                            deadlineAt: request.deadlineAt,
                            participants: 0,
                            questions: request.questions.count,
                            createdAt: currentTest.createdAt,
                            updatedAt: Date()
                        )
                        NotificationCenter.default.post(name: .testUpdatedEvent, object: nil, userInfo: ["test": test])
                        view.showAlert(title: "Сохранено", message: "Изменения сохранены.")
                    }
                } catch {
                    view.showAlert(title: "Ошибка", message: self.localized(error))
                }
            } else {
                // POST /tests
                do {
                    let created = try await model.create(request)
                    current?.id = created.id.uuidString
                    view.setCode(created.code)

                    if publish {
                        self.isPublished = true
                        view.setPublishedUI(true)
                        let test = TestModel(
                            id: created.id.uuidString,
                            code6: String(created.code),
                            title: request.title,
                            published: true,
                            resultsPublished: request.resultsPublished,
                            answersVisible: request.answersVisible,
                            isStopped: false,
                            publishedAt: Date(),
                            deadlineAt: request.deadlineAt,
                            participants: 0,
                            questions: request.questions.count,
                            createdAt: Date(),
                            updatedAt: Date()
                        )
                        NotificationCenter.default.post(name: .testCreatedEvent, object: nil, userInfo: ["test": test])
                        view.showAlert(title: "Опубликовано", message: "Тест успешно создан и опубликован.")
                    } else {
                        let test = TestModel(
                            id: created.id.uuidString,
                            code6: String(created.code),
                            title: request.title,
                            published: false,
                            resultsPublished: request.resultsPublished,
                            answersVisible: request.answersVisible,
                            isStopped: false,
                            publishedAt: nil,
                            deadlineAt: request.deadlineAt,
                            participants: 0,
                            questions: request.questions.count,
                            createdAt: Date(),
                            updatedAt: Date()
                        )
                        NotificationCenter.default.post(name: .testCreatedEvent, object: nil, userInfo: ["test": test])
                        view.showAlert(title: "Сохранено", message: "Тест успешно создан.")
                    }
                } catch {
                    view.showAlert(title: "Ошибка", message: self.localized(error))
                }
            }
        }
    }

    func stopTapped() {
        guard let test = current,
        let id = UUID(uuidString: test.id) else { return }

        Task { @MainActor [weak self] in
            guard let self, let view = self.view else { return }
            view.setLoading(true)
            defer { view.setLoading(false) }

            do {
                _ = try await self.model.stop(id: id)
                self.isPublished = false
                view.setPublishedUI(false)
                view.showAlert(title: "Остановлено", message: "Приём новых попыток остановлен.")
            } catch {
                view.showAlert(title: "Ошибка", message: self.localized(error))
            }
        }
    }

    // MARK: - Validation / Errors
    private func validate(request: CreateTestRequest) -> String? {
        if request.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Введите название теста."
        }
        if let deadline = request.deadlineAt, deadline < Date().addingTimeInterval(5 * 60) {
            return "Дедлайн должен быть не раньше, чем через 5 минут."
        }
        if request.questions.isEmpty {
            return "Добавьте хотя бы один вопрос."
        }
        return nil
    }

    private func localized(_ error: Error) -> String {
        (error as? NetworkError)?.localizedDescription ?? error.localizedDescription
    }
}
