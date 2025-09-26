//
//  TeacherMainPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

final class TestsListMainPresenter: TeacherMainPresenterProtocol {
    weak var view: TeacherMainViewProtocol?
    var model: TeacherMainModelProtocol
    var role: String
    
    init(view: TeacherMainViewProtocol? = nil, model: TeacherMainModelProtocol, role: String) {
        self.view = view
        self.model = model
        self.role = role
        
        registerNotifications()
    }
    
    func viewLoaded() {
        let (email,name) = model.fetchCredentials()
        view?.setCredentials(email,name)
        Task {
            do {
                if role == "student" {
                    let testsResults = try await model.fetchTestsResults()
                    
                    await MainActor.run {
                        view?.setResults(testsResults)
                    }
                    
                } else if role == "teacher" {
                    let tests = try await model.fetchTests()
                    
                    await MainActor.run {
                        view?.showTests(tests)
                    }
                }

            } catch {
                
                await MainActor.run {
                    view?.showError(mapError(error))
                }
            }
        }
    }
    
    func fetchTestsResults() {
        Task {
            do {
                let response = try await model.fetchTestsResults()
                await MainActor.run {
                    view?.setResults(response)
                }
                
            } catch {
                await MainActor.run {
                    view?.showError(error.localizedDescription)
                }
                
            }
        }
    }
    
    func routeNext() {
        if role == "student" {
            view?.routeToMainScreen()
        } else if role == "teacher" {
            view?.routeToTestCreate()
        }
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTestCreatedEvent), name: .testCreatedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTestUpdatedEvent), name: .testUpdatedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTestPublishedEvent), name: .testPublishedEvent, object: nil)
    }
    
    private func mapError(_ error: Error) -> String {
        guard let networkError = error as? NetworkError else { return "Unknown error" }
        switch networkError {
        case .noData:
            return "Unknown error"
        case .decodingError:
            return "Bad input, try later"
        case .internalServerError:
            return "Server error, please, try later"
        case .unknown(let message):
            if let message {
                return message
            } else {
                return "Server error, please, try later"
            }
        case .forbidden:
            return "You dont have access for this action"
        case .notFound:
            return "User with this email not found"
        case .invalidURL:
            return "Server error, try later"
        case .invalidCode:
            return "Bad input, try later"
        }
    }
    
    @objc private func handleTestCreatedEvent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let test = userInfo["test"] as? TestModel {
            view?.addTest(test)
        }
    }
    
    @objc private func handleTestUpdatedEvent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let test = userInfo["test"] as? TestModel {
            view?.updateTest(test)
        }
    }
    
    @objc private func handleTestPublishedEvent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let test = userInfo["test"] as? TestModel {
            view?.updateTest(test)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .testCreatedEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .testUpdatedEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .testPublishedEvent, object: nil)
    }
    
}
