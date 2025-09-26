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
}

@MainActor
protocol AttemptsPresenterProtocol : AnyObject {
    func attach()
    func detach()
    func publish()
    func getStudnts()
}

protocol AttemptsProgressesModelProtocol {
    func getAttemptsRequest() async throws -> EmptyResponse
    func publishResultsRequest(_ request: PublishResultsRequest) async throws -> EmptyResponse
}
