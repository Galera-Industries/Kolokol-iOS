//
//  MainProtocols.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import Foundation

protocol MainModelProtocol {

}

protocol MainViewProtocol: AnyObject {

}

protocol MainPresenterProtocol {
    var keychain: KeychainManagerProtocol { get }
}
