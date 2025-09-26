//
//  MainVC.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

final class MainViewController: UIViewController, MainViewProtocol {
    var presenter: MainPresenterProtocol!

    private var codeFieldBottomToStartButton: NSLayoutConstraint?
    private var codeFieldBottomToKeyboard: NSLayoutConstraint?
    private var code: String?

    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Kollocol"
        label.textColor = Colors.textSecondary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textAlignment = .center
        return label
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setWidth(54)
        imageView.setHeight(54)
        imageView.layer.cornerRadius = 54 / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(hex: "#D9D9D9")
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textPrimary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textSecondary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    // Вертикальный стек имени и почты
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .leading
        return stack
    }()

    // Горизонтальный стек для аватарки и стека с именем и почтой
    private lazy var personInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, infoStackView])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Начать", for: .normal)
        button.setTitleColor(Colors.textPrimary, for: .normal)
        button.backgroundColor = UIColor(hex: "#7C7C7C")?.withAlphaComponent(0.2)
        button.titleLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        button.layer.cornerRadius = 32
        button.setHeight(86)
        button.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ой, такого кода экзамена нет"
        label.textColor = UIColor(hex: "#FA7575")
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.alpha = 0.0
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var systemReadyLabel: UILabel = {
        let label = UILabel()
        label.text = "> Система готова"
        label.textColor = Colors.textPrimary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        label.textAlignment = .left
        return label
    }()

    private lazy var waitingCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "> Ждем код\n экзамена"
        label.textColor = Colors.textPrimary
        label.numberOfLines = 2
        label.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        label.textAlignment = .left
        return label
    }()

    private let codeField = UIDeletableTextField(digitCount: 6, colorScheme: .main)

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: true)
        presenter.viewLoaded()
        configureMainBackground()
        configureConstraints()
        configureCodeField()
        setupDismissKeyboardGesture()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { @MainActor in
            self.codeField.setFocusToFirstField()
        }
    }
    
    // MARK: - Public Methods
    func setCredentials(_ credentials: Credentials, _ email: String) {
        nameLabel.text = credentials.name
        emailLabel.text = email
    }
    
    func routeToTestScreen(_ questions: [StudentQuestion]) {
        navigationController?.pushViewController(TestAssembly.buildStarted(preloadedQuestions: questions), animated: true)
    }
    
    
    // MARK: - Private Methods
    private func configureConstraints() {
        // titleLabel
        view.addSubview(titleLabel)
        titleLabel.pinTop(view.safeAreaLayoutGuide.topAnchor, 16)
        titleLabel.pinCenterX(view.centerXAnchor)

        // personInfoStackView
        view.addSubview(personInfoStackView)
        personInfoStackView.pinHorizontal(view, 16)
        personInfoStackView.pinTop(titleLabel.bottomAnchor, 24)

        // startButton
        view.addSubview(startButton)
        startButton.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 0)
        startButton.pinCenterX(view.centerXAnchor)
        startButton.pinLeft(view.leadingAnchor, 16)

        // codeField
        view.addSubview(codeField)
        codeField.pinCenterX(view.centerXAnchor)
        codeField.pinLeft(view.leadingAnchor, 16)
        codeFieldBottomToStartButton = codeField.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -75)
        codeFieldBottomToStartButton?.isActive = true

        codeFieldBottomToKeyboard = codeField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        codeFieldBottomToKeyboard?.isActive = false

        // errorLabel
        view.addSubview(errorLabel)
        errorLabel.pinTop(codeField.bottomAnchor, 16)
        errorLabel.pinCenterX(view.centerXAnchor)

        // systemReadyLabel
        view.addSubview(systemReadyLabel)
        systemReadyLabel.pinTop(personInfoStackView.bottomAnchor, 100)
        systemReadyLabel.pinCenterX(view.centerXAnchor)
        systemReadyLabel.pinLeft(view.leadingAnchor, 16)

        // waitingCodeLabel
        view.addSubview(waitingCodeLabel)
        waitingCodeLabel.pinTop(systemReadyLabel.bottomAnchor, 16)
        waitingCodeLabel.pinCenterX(view.centerXAnchor)
        waitingCodeLabel.pinLeft(view.leadingAnchor, 16)
    }

    private func configureCodeField() {
        // Любой ввод скрывает ошибку и переключает состояние кнопки
        codeField.onChange = { [weak self] count in
            guard let self else { return }
            self.hideError()
            self.updateStartButtonState(isReady: (count == 6))
            if count != 6 { code = nil }
        }

        // Когда введено 6 символов кнопка активируется
        codeField.onComplete = { [weak self] code in
            self?.updateStartButtonState(isReady: true)
            self?.code = code
        }
    }

    private func updateStartButtonState(isReady: Bool) {
        startButton.isEnabled = isReady
        UIView.animate(withDuration: 0.15) {
            self.startButton.alpha = isReady ? 1.0 : 0.5
        }
    }

    private func showError() {
        errorLabel.isHidden = false
        UIView.animate(withDuration: 0.18) {
            self.errorLabel.alpha = 1.0
        }
    }

    private func hideError() {
        guard errorLabel.alpha > 0.0 else { return }
        UIView.animate(withDuration: 0.12) {
            self.errorLabel.alpha = 0.0
        }
    }

    private func animateAlongsideKeyboard(_ note: Notification) {
        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRootTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc
    private func startButtonPressed() {
        // TODO: - Отправить запрос на бек. В случае если неудача (код не существует) вызвать showError
        guard let code = code else { return }
        presenter.startTest(withCode: code)
    }

    @objc
    private func handleKeyboardWillShow(_ note: Notification) {
        codeFieldBottomToStartButton?.isActive = false
        codeFieldBottomToKeyboard?.isActive = true
        animateAlongsideKeyboard(note)
    }

    @objc
    private func handleKeyboardWillHide(_ note: Notification) {
        codeFieldBottomToKeyboard?.isActive = false
        codeFieldBottomToStartButton?.isActive = true
        animateAlongsideKeyboard(note)
    }

    @objc
    private func handleRootTap() {
        view.endEditing(true)
    }
}

