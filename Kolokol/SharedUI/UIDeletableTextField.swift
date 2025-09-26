//
//  UIDeletableTextField.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import UIKit
import QuartzCore

fileprivate enum Constants {
    static let keyPath: String = "position"
    static let duration: CFTimeInterval = 0.09
    static let repeatCount: Float = 2
    static let shift: CGFloat = 3
    static let colorDuration: CFTimeInterval = 0.1
}

@MainActor
final class UIDeletableTextField: UIView, UIKeyInput {
    struct ColorScheme {
        let base: UIColor
        let filled: UIColor
        let error: UIColor

        static let `default` = ColorScheme(
            base: Colors.surfaceSecondary,
            filled: Colors.surfaceSecondary.withAlphaComponent(0.6),
            error: UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 0.6)
        )

        static let `main` = ColorScheme(
            base: UIColor(hex: "#7C7C7C")?.withAlphaComponent(0.1) ?? .white,
            filled: UIColor(hex: "#7C7C7C")?.withAlphaComponent(0.1) ?? .white,
            error: UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 0.6)
        )
    }

    private let hiddenTextField = CustomTextField()
    var onComplete: ((String) -> Void)?
    var onChange: ((Int) -> Void)? // Для количества введенных символов

    private let digitCount: Int
    private var digits: [Character] = [] {
        didSet { onChange?(digits.count) }
    }
    private var digitLabels: [UILabel] = []

    private let colorScheme: ColorScheme
    private var baseColor: UIColor { colorScheme.base }
    private var filledColor: UIColor { colorScheme.filled }
    private var errorColor: UIColor { colorScheme.error }

    init(digitCount: Int = 4, colorScheme: ColorScheme = .main) {
        self.digitCount = max(1, digitCount)
        self.colorScheme = colorScheme
        super.init(frame: .zero)
        setupView()
    }

    override init(frame: CGRect) {
        self.digitCount = 4
        self.colorScheme = .default
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.digitCount = 4
        self.colorScheme = .default
        super.init(coder: coder)
        setupView()
    }

    override var frame: CGRect {
        get { super.frame }
        set { super.frame = CGRect(origin: newValue.origin, size: intrinsicContentSize) }
    }
    override var intrinsicContentSize: CGSize {
        let cellW: CGFloat = 48, cellH: CGFloat = 80, spacing: CGFloat = 8
        let w = CGFloat(digitCount) * cellW + CGFloat(digitCount - 1) * spacing
        return CGSize(width: w, height: cellH)
    }

    private func setupView() {
        hiddenTextField.keyboardType = .numberPad
        hiddenTextField.textContentType = .oneTimeCode
        hiddenTextField.isHidden = true
        hiddenTextField.forwardKeyInput = self
        addSubview(hiddenTextField)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 8
        addSubview(stack)
        stack.pinTop(topAnchor, 0)
        stack.pinBottom(bottomAnchor, 0)
        stack.pinLeft(leadingAnchor, 0)
        stack.pinRight(trailingAnchor, 0)

        for i in 0..<digitCount {
            let label = UILabel()
            label.backgroundColor = baseColor
            label.textColor = Colors.textPrimary
            label.textAlignment = .center
            label.font = UIFont(name: "TTCommons-DemiBold", size: 24) ?? .systemFont(ofSize: 24, weight: .semibold)
            label.layer.cornerRadius = 16
            label.layer.masksToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 48),
                label.heightAnchor.constraint(equalToConstant: 80)
            ])

            label.isUserInteractionEnabled = true
            label.tag = i
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:))))

            stack.addArrangedSubview(label)
            digitLabels.append(label)
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        isUserInteractionEnabled = true
    }

    func setFocusToFirstField() { hiddenTextField.becomeFirstResponder() }

    func clear() {
        digits.removeAll()
        updateLabels(animated: false)
        hiddenTextField.becomeFirstResponder()
    }

    @objc private func handleTap() { hiddenTextField.becomeFirstResponder() }

    @objc private func handleLabelTap(_ gr: UITapGestureRecognizer) {
        guard let label = gr.view as? UILabel else { return }
        let idx = label.tag
        if idx < digits.count {
            digits = Array(digits.prefix(idx))
            updateLabels()
        }
        hiddenTextField.becomeFirstResponder()
    }

    func shakeAndChangeColor() {
        let shake = CABasicAnimation(keyPath: Constants.keyPath)
        shake.duration = Constants.duration
        shake.repeatCount = Constants.repeatCount
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: center.x - Constants.shift, y: center.y))
        shake.toValue   = NSValue(cgPoint: CGPoint(x: center.x + Constants.shift, y: center.y))
        layer.add(shake, forKey: Constants.keyPath)

        UIView.animate(withDuration: Constants.colorDuration) {
            self.digitLabels.forEach { $0.backgroundColor = self.errorColor }
        }

        Task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            self.clear()
        }
    }

    private func updateLabels(animated: Bool = true) {
        for i in 0..<digitCount {
            let isFilled = i < digits.count
            let targetBG = isFilled ? filledColor : baseColor
            let apply = {
                self.digitLabels[i].text = isFilled ? String(self.digits[i]) : ""
                self.digitLabels[i].backgroundColor = targetBG
            }
            animated ? UIView.animate(withDuration: 0.2, animations: apply) : apply()
        }
    }

    // MARK: UIKeyInput
    var hasText: Bool { !digits.isEmpty }

    func insertText(_ text: String) {
        guard !text.isEmpty else { return }
        var changed = false
        for ch in text where ch.isNumber {
            guard digits.count < digitCount else { break }
            digits.append(ch)
            changed = true
        }
        if changed { updateLabels() }

        if digits.count == digitCount {
            onComplete?(String(digits))
            hiddenTextField.resignFirstResponder()
        }
    }

    func deleteBackward() {
        guard !digits.isEmpty else { return }
        digits.removeLast()
        updateLabels()
    }
}

@MainActor
final class CustomTextField: UITextField, UITextFieldDelegate {
    weak var forwardKeyInput: UIKeyInput?

    override var hasText: Bool { forwardKeyInput?.hasText ?? false }
    override func deleteBackward() { forwardKeyInput?.deleteBackward() }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        forwardKeyInput?.insertText(string)
        return false
    }

    override func paste(_ sender: Any?) {
        if let s = UIPasteboard.general.string {
            forwardKeyInput?.insertText(s)
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        delegate = self
    }
}
