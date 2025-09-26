//
//  AttemptsProgressesPresenter.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

final class AttemptsProgressesPresenter: AttemptsPresenterProtocol {
    func publish() {
        
    }
    
    func fetchStudnts() {
        
    }
    
    private weak var view: AttemptsView?
    private let testId: UUID
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
