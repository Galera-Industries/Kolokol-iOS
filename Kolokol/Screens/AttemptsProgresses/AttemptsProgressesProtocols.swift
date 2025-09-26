//
//  AttemptsProgressesProtocols.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

@MainActor
protocol AttemptsView : AnyObject {
    func render(items: [AttemptDisplayItem], animate: Bool)
    func showPublishResult()
    func showError(msg: String)
    func showGetStudents(items: [AttemptDisplayItem])
}

@MainActor
protocol AttemptsPresenterProtocol : AnyObject {
    func attach()
    func detach()
    func publish()
    func getStudents()
}

protocol AttemptsProgressesModelProtocol {
    func getAttemptsRequest(_ testId: UUID) async throws -> GetAttemptsResponse
    func publishResultsRequest(_ request: PublishResultsRequest, testId: UUID) async throws -> EmptyResponse
}
