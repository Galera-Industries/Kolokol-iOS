//
//  AuthorizationVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

import UIKit

final class AuthorizationView: UIViewController, AuthorizationViewProtocol {

    // MARK: - Variables
    var presenter: AuthorizationPresenterProtocol!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI
    private func configureUI() {
        
    }
    
    // MARK: - Protocol methods
    func showError(_ error: String) {
        let alertController = UIAlertController(title: "Ooops, error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok, this is terrible", style: .default)
        alertController.addAction(ok)
        self.present(alertController, animated: true)
    }
    
    func routeNext() {
        // navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
    }
}
