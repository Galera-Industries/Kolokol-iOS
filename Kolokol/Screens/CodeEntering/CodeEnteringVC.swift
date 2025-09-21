//
//  CodeEnteringVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import UIKit

final class CodeEnteringViewController: UIViewController, CodeEnteringViewProtocol {
    
    var presenter: CodeEnteringPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
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
    
    func routeNext(_ isStudent: Bool) {
        <#code#>
    }
}


