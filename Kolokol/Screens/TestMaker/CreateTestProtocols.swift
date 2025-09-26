//
//  CreateTestProtocols.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import Foundation

protocol CreateTestModelProtocol {
    func fetchEdit(id: UUID) async throws -> EditTestResponse
    func create(_ request: CreateTestRequest) async throws -> CreateTestResponse
    func update(id: UUID, _ request: CreateTestRequest) async throws -> EmptyResponse
    func stop(id: UUID) async throws -> EmptyResponse
    func fetchStudents() async throws -> GetStudentsResponse
}

@MainActor
protocol CreateTestViewProtocol: AnyObject {
    var test: TestModel? { get set }

    func setLoading(_ loading: Bool)
    func fillFromEdit(_ dto: EditTestResponse)
    func setCode(_ code: Int)
    func setPublishedUI(_ published: Bool)
    func showAlert(title: String, message: String)
    func routeToProgress(for id: UUID)
    func setStudents(all: [GetStudentsResponse.Student])
//    func setAssignedStudents(_ selected: StudentSelection)
}

protocol CreateTestPresenterProtocol: AnyObject {
    func viewDidLoad()
    func saveTapped(request: CreateTestRequest, publish: Bool)
    func stopTapped()
    func chooseStudentsOpened()
}
