//
//  AuthorizationVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 20.09.2025.
//

import UIKit

final class AuthorizationViewController: UIViewController, AuthorizationViewProtocol {

    var presenter: AuthorizationPresenterProtocol?

    private let titleLabel: UILabel = UILabel()
    private let emailLabel: UILabel = UILabel()
    private let emailTextField: UITextField = UITextField()
    private let domainLabel: UILabel = UILabel()
    private lazy var emailStackView: UIStackView = UIStackView(arrangedSubviews: [emailTextField, domainLabel])
    private let getCodeButton: UIButton = UIButton(type: .system)
    
    // MARK: - Protocol methods
    func showError(_ error: String) {
        let alertController = UIAlertController(title: "Ooops, error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok, this is terrible", style: .default)
        alertController.addAction(ok)
        self.present(alertController, animated: true)
    }
    
    func routeNext() {
        navigationController?.pushViewController(CodeEnteringAssembly.build(), animated: true)
    }
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        super.viewDidLoad()
        configureBackground()
        configureUI()
    }
    
    // MARK: - UI
    private func configureUI() {
        configureTitleLabel()
        configureEmailStackView()
        configureEmailLabel()
        configureDomainLabel()
        configureEmailTextField()
        configureGetCodeButton()
    }

    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "Kollocol"
        titleLabel.textColor = Colors.textSecondary
        titleLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        titleLabel.textAlignment = .center
        titleLabel.pinTop(view.safeAreaLayoutGuide.topAnchor, 16)
        titleLabel.pinCenterX(view.centerXAnchor)
    }
    
    private func configureEmailStackView() {
        view.addSubview(emailStackView)
        emailStackView.axis = .horizontal
        emailStackView.alignment = .center
        emailStackView.spacing = 2
        emailStackView.distribution = .fill
        emailStackView.pinCenterY(view.centerYAnchor)
        emailStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emailStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            emailStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    private func configureEmailTextField() {
        emailTextField.delegate = self
        emailTextField.textColor = Colors.textPrimary
        emailTextField.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        emailTextField.tintColor = .white
        emailTextField.minimumFontSize = 14
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = ""
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.textAlignment = .right
        emailTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        emailTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func configureEmailLabel() {
        view.addSubview(emailLabel)
        emailLabel.text = "Email"
        emailLabel.textColor = Colors.textSecondary
        emailLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        emailLabel.textAlignment = .center
        emailLabel.pinBottom(emailStackView.topAnchor, 8)
        emailLabel.pinCenterX(view.centerXAnchor)
    }
    
    private func configureDomainLabel() {
        domainLabel.text = "@edu.hse.ru"
        domainLabel.textColor = Colors.textSecondary
        domainLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        domainLabel.adjustsFontSizeToFitWidth = true
        domainLabel.minimumScaleFactor = 0.5
        domainLabel.isUserInteractionEnabled = true
        domainLabel.setContentHuggingPriority(.required, for: .horizontal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDomainLabelTap))
        domainLabel.addGestureRecognizer(tapGesture)
    }
    
    private func configureGetCodeButton() {
        view.addSubview(getCodeButton)
        getCodeButton.setTitle("Получить код", for: .normal)
        getCodeButton.setTitleColor(Colors.textPrimary, for: .normal)
        getCodeButton.backgroundColor = Colors.surfacePrimary
        getCodeButton.titleLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        getCodeButton.layer.cornerRadius = 32
        getCodeButton.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 20)
        getCodeButton.pinLeft(view.leadingAnchor, 16)
        getCodeButton.pinRight(view.trailingAnchor, 16)
        getCodeButton.setHeight(86)
        
        getCodeButton.addTarget(self, action: #selector(getCodeButtonPressed), for: .touchUpInside)
    }
    
    private func checkEmailCorrectness() -> Bool {
        guard let email = emailTextField.text else { return false }
        if email.isEmpty {
            return false
        }
        if email.first == "." || email.first == "-" || email.first == "_" {
            return false
        }
        return true
    }

    @objc private func handleDomainLabelTap() {
        emailTextField.becomeFirstResponder()
    }
    
    @objc private func getCodeButtonPressed() {
        if !checkEmailCorrectness() { showError("Input correct email!"); return }
        guard let email = emailTextField.text else { return }
        let fullEmail = email + "@edu.hse.ru"
        presenter?.sendEmailButtonPressed(withEmail: fullEmail)
    }
    

    @objc private func dismissKeyboard() {
        if emailTextField.isFirstResponder {
            view.endEditing(true)
        } else {
            emailTextField.becomeFirstResponder()
        }
    }
}

// MARK: - UITextFieldDelegate
extension AuthorizationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textIgnore = CharacterSet(charactersIn: "!@#$%^&*()~=[]+`|{}?' '")
        if string.rangeOfCharacter(from: textIgnore) != nil {
             return false
        }
        
        let cur = textField.text ?? ""
        guard let ran = Range(range, in: cur) else { return false }
        let updated = cur.replacingCharacters(in: ran, with: string)
        textField.adjustsFontSizeToFitWidth = !updated.isEmpty && updated.count > 10
        return updated.count <= 32
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if checkEmailCorrectness() {
            getCodeButtonPressed()
        } else {
            showError("Input correct email!")
        }
        return true
    }
}
