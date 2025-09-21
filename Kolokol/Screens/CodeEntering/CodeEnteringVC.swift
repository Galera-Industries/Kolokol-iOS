//
//  CodeEnteringVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import UIKit

final class CodeEnteringViewController: UIViewController, CodeEnteringViewProtocol {
    
    var presenter: CodeEnteringPresenterProtocol!
    
    private let titleLabel: UILabel = UILabel()
    private let codeLabel: UILabel = UILabel()
    private var digitsStackView: UIStackView = UIStackView()
    private let sendCodeAgainButton: UIButton = UIButton(type: .system)
    private var countdownTimer: Timer?
    let timerDuration: TimeInterval = 5.0
    var remainingTime: TimeInterval = 0
    private var textFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureUI()
    }
    
    // MARK: - UI
    
    private func configureUI() {
        configureTitleLabel()
        configureDigitsStackView()
        configureCodeLabel()
        configureSendCodeAgainButton()
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
    
    private func configureCodeLabel() {
        view.addSubview(codeLabel)
        codeLabel.text = "Код"
        codeLabel.textColor = Colors.textSecondary
        codeLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        codeLabel.textAlignment = .center
        codeLabel.pinBottom(digitsStackView.topAnchor, 8)
        codeLabel.pinCenterX(view.centerXAnchor)
    }
    
    private func configureDigitsStackView() {
        view.addSubview(digitsStackView)
        digitsStackView.axis = .horizontal
        digitsStackView.distribution = .fillEqually
        digitsStackView.spacing = 10
        
        for i in 0..<4 {
            let textField = UIDeletableTextField()
            textField.backgroundColor = Colors.surfaceSecondary
            textField.layer.borderColor = .none
            textField.layer.cornerRadius = 20
            textField.textAlignment = .center
            textField.font = UIFont(name: "TTCommons-DemiBold", size: 24)
            textField.textColor = Colors.textPrimary
            textField.keyboardType = .numberPad
            textField.delegate = self
            textField.tag = i
            digitsStackView.addArrangedSubview(textField)
            textFields.append(textField)
        }
        
        digitsStackView.setHeight(80)
        digitsStackView.pinCenterY(view)
        digitsStackView.pinCenterX(view)
        digitsStackView.pinLeft(view.leadingAnchor, 80)
        digitsStackView.pinRight(view.trailingAnchor, 80)
    }
    
    private func configureSendCodeAgainButton() {
        view.addSubview(sendCodeAgainButton)
        let buttonText = "Отправить снова" + " (" + "\(formatTime(Int(timerDuration)))" + ")"
        sendCodeAgainButton.setTitle(buttonText, for: .normal)
        remainingTime = timerDuration
        startCountdown()
        
        sendCodeAgainButton.setTitleColor(Colors.textSecondary, for: .normal)
        sendCodeAgainButton.backgroundColor = Colors.surfaceSecondary
        sendCodeAgainButton.titleLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        sendCodeAgainButton.layer.cornerRadius = 32
        sendCodeAgainButton.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 20)
        sendCodeAgainButton.pinLeft(view.leadingAnchor, 16)
        sendCodeAgainButton.pinRight(view.trailingAnchor, 16)
        sendCodeAgainButton.setHeight(86)
        
        sendCodeAgainButton.isEnabled = false
        sendCodeAgainButton.addTarget(self, action: #selector(sendCodeAgainButtonPressed), for: .touchUpInside)
    }
    
    // MARK: - Protocol methods
    
    func showError(_ error: String) {
        let alertController = UIAlertController(title: "Ooops, error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok, this is terrible", style: .default)
        alertController.addAction(ok)
        self.present(alertController, animated: true)
    }
    
    func routeNext(_ isStudent: Bool) {
        // Code for routing
    }
    
    // MARK: - Private
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startCountdown() {
        countdownTimer = Timer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateLabel),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(countdownTimer ?? Timer(), forMode: .common)
    }
    
    private func hideTimer() {
        UIView.performWithoutAnimation {
            sendCodeAgainButton.setTitle("Отправить снова", for: .normal)
            sendCodeAgainButton.setTitleColor(Colors.textPrimary, for: .normal)
            sendCodeAgainButton.backgroundColor = Colors.surfacePrimary
            sendCodeAgainButton.layoutIfNeeded()
        }
    }
    
    @objc private func updateLabel() {
        remainingTime -= 1
        if remainingTime >= 0 {
            let buttonText = "Отправить снова" + " (" + "\(formatTime(Int(remainingTime)))" + ")"
            UIView.performWithoutAnimation {
                sendCodeAgainButton.setTitle(buttonText, for: .normal)
                sendCodeAgainButton.layoutIfNeeded()
            }
        } else {
            countdownTimer?.invalidate()
            sendCodeAgainButton.isEnabled = true
            hideTimer()
        }
    }
    
    @objc private func sendCodeAgainButtonPressed() {
        let buttonText = "Отправить снова" + " (" + "\(formatTime(Int(timerDuration)))" + ")"
        UIView.performWithoutAnimation {
            sendCodeAgainButton.setTitle(buttonText, for: .normal)
            sendCodeAgainButton.setTitleColor(Colors.textSecondary, for: .normal)
            sendCodeAgainButton.backgroundColor = Colors.surfaceSecondary
            sendCodeAgainButton.isEnabled = false
            sendCodeAgainButton.layoutIfNeeded()
        }
        remainingTime = timerDuration
        startCountdown()
    }
}

// MARK: - UITextFieldDelegate Extension
extension CodeEnteringViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !isOnlyDigitsInString(string)
            { return false }
        
        if string.count > 1 {
            pasteString(string)
            return false
        }
        
        if !isInputDigitsOrDeleting(textField, string) {
            return false
        }
        
        if string.isEmpty {
            handleDelete(textField)
        } else {
            handleInput(textField, string)
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    }
    
    private func pasteString(_ string: String) {
        
        for field in textFields {
            field.text = ""
        }
        
        putOneCharacterInOneField(string)
        setLastTextFieldAsResponder(string)
        
        if areAllTextFieldsFilled() {
            textFieldFilled()
        }
    }
    
    private func handleDelete(_ textField: UITextField) {
        if textField.tag > 0 {
            clearCell(textField.tag)
            setPreviousTextFieldAsResponder(textField)
        } else if textField.tag == 0 {
            clearCell(textField.tag)
        }
    }
    
    private func isInputDigitsOrDeleting(_ textField: UITextField, _ string: String) -> Bool {
        guard let _ = textField.text, string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil || string.isEmpty else {
            return false
        }
        return true
    }
    
    private func handleInput(_ textField: UITextField, _ string: String) {
        textField.text = string
        
        moveToNextTextField(textField)
        
        if areAllTextFieldsFilled() {
            textFieldFilled()
        }
    }
    
    private func moveToNextTextField(_ textField: UITextField) {
        let nextTag = textField.tag + 1
        if nextTag < textFields.count {
            textFields[nextTag].becomeFirstResponder()
        }
    }
    
    private func clearCell(_ textFieldTag: Int) {
        textFields[textFieldTag].text = ""
    }
    
    private func setPreviousTextFieldAsResponder(_ textField: UITextField) {
        let prevTag = textField.tag - 1
        textFields[prevTag].becomeFirstResponder()
    }
    
    private func isOnlyDigitsInString(_ string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        return true
    }
    
    private func putOneCharacterInOneField(_ string: String) {
        for (index, char) in string.enumerated() {
            if index < textFields.count {
                textFields[index].text = String(char)
            }
        }
    }
    
    private func areAllTextFieldsFilled() -> Bool {
        for field in textFields {
            if field.text?.isEmpty == true {
                return false
            }
        }
        return true
    }
    
    private func setLastTextFieldAsResponder(_ string: String) {
        if string.count <= textFields.count {
            textFields[string.count - 1].becomeFirstResponder()
        } else {
            textFields.last?.becomeFirstResponder()
        }
    }
    
    private func getCodeFromTextFields() -> String {
        var code: String = ""
        
        for field in textFields {
            guard let text = field.text, !text.isEmpty else {
                print("Empty text field found")
                return code
            }
            code.append(text)
        }
        print(code)
        return code
    }
    
    private func textFieldFilled() {
        let otpString = getCodeFromTextFields()
        presenter.textFieldFilled(withStringCode: otpString)
    }
}

