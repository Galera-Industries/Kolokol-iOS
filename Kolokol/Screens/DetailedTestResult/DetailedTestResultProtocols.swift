//
//  DetailedTestResultProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import Foundation

protocol DetailedTestResultModelProtocol {
    func fetchDetailedResults(_ testID: UUID) async throws -> DetailedTestResult // для студента
    func loadCredentials() -> Credentials
}

protocol DetailedTestResultPresenterProtocol {
    var isStudent: Bool { get }
    func viewLoaded()
}

protocol DetailedTestResultViewProtocol: AnyObject {
    func showReviews(_ reviews: [Item])
    func setName(_ name: String)
    func setGrade(_ grade: Int)
    func stopRefresherIfNeeded()
}
