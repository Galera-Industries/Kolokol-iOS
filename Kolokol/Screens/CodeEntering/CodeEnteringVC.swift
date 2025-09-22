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
    private let codeField = UIDeletableTextField()
    private let sendCodeAgainButton: UIButton = UIButton(type: .system)
    private var countdownTimer: Timer?
    let timerDuration: TimeInterval = 60.0
    var remainingTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { @MainActor [weak self] in
            self?.codeField.setFocusToFirstField()
        }
    }
    
    // MARK: - UI
    private func configureUI() {
        configureTitleLabel()
        configureCodeField()
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
        codeLabel.pinBottom(codeField.topAnchor, 8)
        codeLabel.pinCenterX(view.centerXAnchor)
    }
    
    private func configureCodeField() {
        view.addSubview(codeField)
        codeField.clipsToBounds = true
        
        codeField.pinCenterY(view)
        codeField.pinCenterX(view)
        codeField.pinCenterX(view.centerXAnchor)
        
        codeField.onComplete = { [weak self] code in
            self?.presenter.textFieldFilled(withStringCode: code)
        }
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
        codeField.shakeAndChangeColor()
        
        let alertController = UIAlertController(title: "Ooops, error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok, this is terrible", style: .default)
        alertController.addAction(ok)
        self.present(alertController, animated: true)
    }
    
    func routeNext(_ isComplete: Bool) {
        if isComplete {
            //
        } else {
            navigationController?.pushViewController(CredentialsAssembly.build(), animated: true)
        }
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
        
        codeField.clear()
    }
}
