//
//  CredentialVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import UIKit

final class CredentialsViewController: UIViewController {
    
    var presenter: CredentialsPresenterProtocol!
    
    private let titleLabel: UILabel = UILabel()
    private let greetingLabel: UILabel = UILabel()
    private let nameTextField: UITextField = UITextField()
    private let usernameTextField: UITextField = UITextField()
    private let tgTextField: UITextField = UITextField()
    private lazy var credentialsStackView:
    UIStackView = UIStackView(arrangedSubviews: [nameTextField, usernameTextField, tgTextField])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        configureUI()
    }
    
    private func configureUI() {
        
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
