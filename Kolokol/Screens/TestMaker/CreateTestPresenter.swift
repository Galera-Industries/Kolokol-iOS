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
    private var currentID: UUID?
    private var isPublished = false

    // MARK: - Init
    init(view: CreateTestViewProtocol, model: CreateTestModelProtocol, initialID: UUID?) {
        self.view = view
        self.model = model
        self.currentID = initialID
    }

    // MARK: - Lifecycle
    func viewDidLoad() {
        guard let id = currentID else { return }

        Task { @MainActor [weak self] in
            guard let self, let view = self.view else { return }
            view.setLoading(true)
            defer { view.setLoading(false) }

            do {
                let dto = try await self.model.fetchEdit(id: id)
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

            if let id = self.currentID {
                // PUT /tests/{id}
                do {
                    _ = try await self.model.update(id: id, request)
                    if publish {
                        self.isPublished = true
                        view.setPublishedUI(true)
                        view.showAlert(title: "Опубликовано", message: "Тест успешно опубликован.")
                    } else {
                        view.showAlert(title: "Сохранено", message: "Изменения сохранены.")
                    }
                } catch {
                    view.showAlert(title: "Ошибка", message: self.localized(error))
                }
            } else {
                // POST /tests
                do {
                    let created = try await self.model.create(request)
                    if let uuid = UUID(uuidString: created.id.uuidString) {
                        self.currentID = uuid
                    }
                    view.setCode(created.code)

                    if publish {
                        self.isPublished = true
                        view.setPublishedUI(true)
                        view.showAlert(title: "Опубликовано", message: "Тест успешно создан и опубликован.")
                    } else {
                        view.showAlert(title: "Сохранено", message: "Тест успешно создан.")
                    }
                } catch {
                    view.showAlert(title: "Ошибка", message: self.localized(error))
                }
            }
        }
    }

    func stopTapped() {
        guard let id = currentID else { return }

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
        return nil
    }

    private func localized(_ error: Error) -> String {
        (error as? NetworkError)?.localizedDescription ?? error.localizedDescription
    }
}
