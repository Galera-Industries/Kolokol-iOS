//
//  TeacherMainProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

protocol TeacherMainModelProtocol: StudentTestFetchProtocol {
    func fetchTests() async throws -> [TestModel] // для поиска тестов преподавателя
    func fetchCredentials() -> (String, String) // для загрузки почты имени
}

protocol TeacherMainPresenterProtocol {
    func viewLoaded() // для загрузки тестов преподавателя
    func fetchTestsResults() // для студента
    var role: String { get }
    func routeNext()
}

protocol TeacherMainViewProtocol: AnyObject {
    func showTests(_ tests: [TestModel]) // для установки тестов в таблицу
    func addTest(_ test: TestModel) // для добавления 1 теста в таблицу
    func updateTest(_ test: TestModel) // для обновления состояния теста(количество вопросов, опубликован)
    func showError(_ error: String) // для вывода нужной ошибки на экран
    func setCredentials(_ email: String, _ name: String)
    func routeToMainScreen() // для студента
    func routeToTestCreate() // для учителя
    func setResults(_ results: [TestResult]) // для студента
}

protocol StudentTestFetchProtocol {
    func fetchTestsResults() async throws -> [TestResult]
}
