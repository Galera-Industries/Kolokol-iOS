//
//  DetailedTestResultPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import Foundation

final class DetailedTestResultPresenter: DetailedTestResultPresenterProtocol {
    weak var view: DetailedTestResultViewProtocol?
    var model: DetailedTestResultModelProtocol
    var isStudent: Bool
    var testResult: TestResult?
    
    init(view: DetailedTestResultViewProtocol? = nil, model: DetailedTestResultModelProtocol, isStudent: Bool, testResult: TestResult? = nil) {
        self.view = view
        self.model = model
        self.isStudent = isStudent
        self.testResult = testResult
    }
    
    func viewLoaded() {
        if isStudent {
            configureForStudent()
        }
    }
    
    private func configureForStudent() {
        guard let testResult = testResult else { return }
        
        let name = model.loadCredentials().name
        view?.setName(name)
        view?.setGrade(testResult.grade10 ?? -1) // если -1 значит не оценена работа
        
        Task {
            do {
                let response = try await model.fetchDetailedResults(testResult.testId)
                await MainActor.run {
                    view?.showReviews(response.items)
                }
            } catch {
                await MainActor.run {
                    view?.stopRefresherIfNeeded()
                }
            }
        }
    }
}
