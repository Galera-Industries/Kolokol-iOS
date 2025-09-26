//
//  CredentialVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import UIKit

final class CredentialsViewController: UIViewController, CredentialsViewProtocol {
    var presenter: CredentialsPresenterProtocol!
    
    private var kolokol: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let greetingLabel: UILabel = UILabel()
    private var nameTextField: UITextField = UITextField()
    private var usernameTextField: UITextField = UITextField()
    private var tgTextField: UITextField = UITextField()
    private let saveButton: UIButton = UIButton(type: .system)
    
    /// Не ругайтесь, иначе не знаю как сделать
    var greetingCenterXAnchor: NSLayoutConstraint?
    var greetingCenterYAnchor: NSLayoutConstraint?
    var greetingTopAnchor: NSLayoutConstraint?
    var greetingLeadingAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        navigationItem.setHidesBackButton(true, animated: true)
        configureBackground()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { @MainActor in
            setFocusOn(nameTextField)
        }
    }
    
    func routeNext() {
        navigationController?.pushViewController(TestsListMainAssembly.build(role: "student"), animated: true)
    }
    
    func showError(_ error: String) {
        let alertController = UIAlertController(title: "Ooops, error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok, this is terrible", style: .default)
        alertController.addAction(ok)
        self.present(alertController, animated: true)
    }
    
    private func configureUI() {
        configureTitleLabel()
        configureGreetingLabel()
        configureKolokol()
        configureNameTextField()
        configureUsernameTextField()
        configureTgTextField()
        configureSaveButton()
    }
    
    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "Kollocol"
        titleLabel.textColor = Colors.textSecondary
        titleLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        titleLabel.pinTop(view.safeAreaLayoutGuide.topAnchor, 16)
        titleLabel.pinCenterX(view.centerXAnchor)
    }
    
    private func configureGreetingLabel() {
        view.addSubview(greetingLabel)
        greetingLabel.text = "Познакомимся"
        greetingLabel.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        greetingLabel.textColor = Colors.textPrimary
        greetingCenterXAnchor = greetingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        greetingCenterXAnchor?.isActive = true
        greetingCenterYAnchor = greetingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        greetingCenterYAnchor?.isActive = true
        greetingTopAnchor = greetingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        greetingTopAnchor?.isActive = false
        greetingLeadingAnchor = greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        greetingLeadingAnchor?.isActive = false
        greetingLabel.textAlignment = .center
        greetingLabel.setWidth(290)
        greetingLabel.setHeight(46)
    }
    
    private func configureKolokol() {
        view.addSubview(kolokol)
        kolokol.image = UIImage(named: "kolokol")
        kolokol.pinCenterX(view)
        kolokol.setHeight(70)
        kolokol.setWidth(64)
        kolokol.pinBottom(greetingLabel.topAnchor, 26)
        kolokol.shakeWith(duration: 1, angle: 0.5, yOffset: 0.5) { _ in
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                self.greetingCenterXAnchor?.isActive = false
                self.greetingCenterYAnchor?.isActive = false
                self.greetingTopAnchor?.isActive = true
                self.greetingLeadingAnchor?.isActive = true
                self.view.layoutIfNeeded()
                self.nameTextField.alpha = 1
                self.usernameTextField.alpha = 1
                self.tgTextField.alpha = 1
                self.saveButton.alpha = 1
                self.kolokol.alpha = 0
            })
        }
    }
    
    private func configureNameTextField() {
        nameTextField = createTextField("Имя")
        nameTextField.pinHorizontal(view, 16)
        nameTextField.pinTop(greetingLabel.bottomAnchor, 16)
        nameTextField.alpha = 0
    }
    
    private func configureUsernameTextField() {
        usernameTextField = createTextField("Фамилия")
        usernameTextField.pinHorizontal(view, 16)
        usernameTextField.pinTop(nameTextField.bottomAnchor, 0)
        usernameTextField.alpha = 0
    }
    
    private func configureTgTextField() {
        tgTextField = createTextField("@Telegram")
        tgTextField.pinHorizontal(view, 16)
        tgTextField.pinTop(usernameTextField.bottomAnchor, 0)
        tgTextField.accessibilityIdentifier = "tgTextField"
        tgTextField.alpha = 0
    }
    
    private func configureSaveButton() {
        view.addSubview(saveButton)
        saveButton.setTitle("Далее", for: .normal)
        saveButton.setTitleColor(Colors.textSecondary, for: .normal)
        saveButton.backgroundColor = Colors.surfaceSecondary
        saveButton.titleLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        saveButton.layer.cornerRadius = 32
        saveButton.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 20)
        saveButton.pinLeft(view.leadingAnchor, 16)
        saveButton.pinRight(view.trailingAnchor, 16)
        saveButton.setHeight(86)
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.alpha = 0
    }
    
    private func createTextField(_ placeholder: String) -> UITextField {
        let textField = UITextField()
        view.addSubview(textField)
        textField.delegate = self
        textField.layer.cornerRadius = 32
        textField.textColor = Colors.textPrimary
        textField.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        textField.tintColor = .white
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.textAlignment = .left
        textField.returnKeyType = .done
        textField.backgroundColor = Colors.surfaceSecondary
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.setHeight(70)
        textField.setWidth(361)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Colors.textSecondary]
        )
        return textField
    }
    
    private func setFocusOn(_ view: UIView) {
        view.becomeFirstResponder()
    }
    
    private func updateButton() {
        guard let name = nameTextField.text,
              let username = usernameTextField.text,
              let tg = tgTextField.text else { return }
        
        if !name.isEmpty && !username.isEmpty && !tg.isEmpty && tg != "@" {
            saveButton.isEnabled = true
            saveButton.backgroundColor = Colors.surfacePrimary
            saveButton.setTitleColor(Colors.textPrimary, for: .normal)
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = Colors.surfaceSecondary
            saveButton.setTitleColor(Colors.textSecondary, for: .normal)
        }
    }
    
    @objc private func saveButtonPressed() {
        guard let name = nameTextField.text,
              let username = usernameTextField.text,
              let tg = tgTextField.text else { return }
        if name.isEmpty || username.isEmpty || tg.isEmpty { return }
        presenter.saveButtonPressed(name, username, tg)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CredentialsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textIgnore = CharacterSet(charactersIn: "' '")
        if string.rangeOfCharacter(from: textIgnore) != nil {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateButton()
        if textField.accessibilityIdentifier == "tgTextField" {
            if let text = textField.text {
                if text.first != "@" {
                    textField.text = "@" + text
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.isFirstResponder {
            setFocusOn(usernameTextField)
        } else if usernameTextField.isFirstResponder {
            setFocusOn(tgTextField)
        } else {
            dismissKeyboard()
            saveButtonPressed()
        }
        return true
    }
}
