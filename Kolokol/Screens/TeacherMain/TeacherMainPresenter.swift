//
//  TeacherMainPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

final class TeacherMainPresenter: TeacherMainPresenterProtocol {
    weak var view: TeacherMainViewProtocol?
    var model: TeacherMainModelProtocol
    
    init(view: TeacherMainViewProtocol? = nil, model: TeacherMainModelProtocol) {
        self.view = view
        self.model = model
    }
    
    func viewLoaded() {
        Task {
            do {
                let tests = try await model.fetchTests()
                
                await MainActor.run {
                    view?.showTests(tests)
                }
                
            } catch {
                
                await MainActor.run {
                    view?.showError(mapError(error))
                }
            }
        }
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
    
}
