//
//  AttemptsProgressesProtocols.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation

@MainActor
protocol AttemptsView: AnyObject {
    func render(items: [AttemptDisplayItem], animate: Bool)
}

import Foundation

@MainActor
protocol AttemptsPresenterProtocol: AnyObject {
    func attach()
    func detach()
}
