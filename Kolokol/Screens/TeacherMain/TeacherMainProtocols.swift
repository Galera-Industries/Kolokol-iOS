//
//  TeacherMainProtocols.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import Foundation

protocol TeacherMainModelProtocol {
    func fetchTests() async throws -> [TestModel] // для поиска тестов преподавателя
}

protocol TeacherMainPresenterProtocol {
    func viewLoaded() // для загрузки тестов преподавателя
}

protocol TeacherMainViewProtocol: AnyObject {
    func showTests(_ tests: [TestModel]) // для установки тестов в таблицу
    func showError(_ error: String) // для вывода нужной ошибки на экран
}
