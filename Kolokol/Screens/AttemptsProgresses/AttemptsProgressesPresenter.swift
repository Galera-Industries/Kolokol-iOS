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
    private let bearer: String
    
    private var itemsById: [UUID: AttemptDisplayItem] = [:]
    private var streamTask: Task<Void, Never>?
    
    init(view: AttemptsView, testId: UUID, bearer: String) {
        self.view = view
        self.testId = testId
        self.bearer = bearer
    }
    
    func attach() {
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
        if let old = itemsById[e.attempt_id], e.answered < old.answered {
            return
        }
        let item = AttemptDisplayItem(
            attemptId: e.attempt_id,
            firstName: e.first_name,
            lastName: e.last_name,
            answered: e.answered,
            total: e.total,
            updatedAt: e.updated_at
        )
        itemsById[e.attempt_id] = item
    }
    
    private func apply(animated: Bool) {
        let items = itemsById.values.sorted { $0.updatedAt > $1.updatedAt }
        view?.render(items: items, animate: animated)
    }
}


struct AttemptDisplayItem: Hashable {
    let attemptId: UUID
    let firstName: String
    let lastName: String
    let answered: Int
    let total: Int
    let updatedAt: Date
    
    var fullName: String { "\(lastName) \(firstName)" }
}
