//
//  AttemptsProgressesPresenter.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

final class AttemptsProgressesPresenter: AttemptsPresenterProtocol {
    private weak var view: AttemptsView?
    private let testId: UUID
    var model: AttemptsProgressesModelProtocol?
    private let keychain: KeychainManagerProtocol
    
    private var itemsById: [UUID: AttemptDisplayItem] = [:]
    private var streamTask: Task<Void, Never>?
    
    init(view: AttemptsView, testId: UUID, keychain: KeychainManagerProtocol) {
        self.view = view
        self.testId = testId
        self.keychain = keychain
    }
    
    func attach() {
        guard let bearer = keychain.getString(key: KeychainManager.keyForSaveAccessToken) else { return }
        let stream = WebSocketService.shared.openTestProgressStream(testId: testId, bearer: bearer)
        streamTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await msg in stream {
                    await MainActor.run {
                        self.handle(message: msg)
                    }
                }
            } catch {
            }
        }
    }
    
    func detach() {
        streamTask?.cancel()
        WebSocketService.shared.close(withReason: "Attempts screen detached")
    }
    
    // MARK: - Handle incoming events
    private func handle(message: TestWSMessage) {
        switch message {
        case .connection(_):
            break
            
        case .snapshot(let snap):
            for e in snap.items {
                upsert(from: e)
            }
            apply(animated: false)
            
        case .studentJoined(let e):
            upsert(from: e)
            apply(animated: true)
            
        case .studentProgress(let e):
            upsert(from: e)
            apply(animated: true)
            
        case .unknown:
            break
        }
    }
    
    private func upsert(from e: StudentEventData) {
        if let old = itemsById[e.attemptId], e.answered < old.answered {
            return
        }
        let item = AttemptDisplayItem(
            attemptId: e.attemptId,
            firstName: e.firstName,
            lastName: e.lastName,
            answered: e.answered,
            total: e.total,
            updatedAt: e.updatedAt,
            tg: e.tg,
            assessed: e.assessed,
            result: e.result
        )
        itemsById[e.attemptId] = item
    }
    
    private func apply(animated: Bool) {
        let items = itemsById.values.sorted { $0.updatedAt > $1.updatedAt }
        view?.render(items: items, animate: animated)
    }
    
    func publish() {
        Task {
            do {
                let req = PublishResultsRequest(publish: true)
                let resp = try await model?.publishResultsRequest(req, testId: testId)
                await MainActor.run {
                    view?.showPublishResult()
                }
            } catch {
                await MainActor.run {
                    view?.showError(msg: error.localizedDescription)
                }
            }
        }
    }
    
    func getStudents() {
        Task {
            do {
                let resp = try await model?.getAttemptsRequest(testId)
                guard let resp = resp else { return }
                var items: [AttemptDisplayItem] = []
                for item in resp.items {
                    let newItem = AttemptDisplayItem(
                        attemptId: item.attemptId,
                        firstName: item.firstName,
                        lastName: item.lastName,
                        answered: item.answered,
                        total: item.total,
                        updatedAt: Date(),
                        tg: item.tg,
                        assessed: item.assessed == "done",
                        result: item.result
                    )
                    items.append(newItem)
                }
                await MainActor.run {
                    view?.showGetStudents(items: items)
                }
            } catch {
                await MainActor.run {
                    view?.showError(msg: error.localizedDescription)
                }
            }
        }
    }
}


struct AttemptDisplayItem: Hashable {
    let attemptId: UUID
    let firstName: String
    let lastName: String
    let answered: Int
    let total: Int
    let updatedAt: Date
    let tg: String
    let assessed: Bool
    let result: Int?
    var fullName: String { "\(lastName) \(firstName)" }
}
