//
//  TitleInputView.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

final class TitleInputView: UIView, UITextViewDelegate {
    private let tv: AdjustedTextView = {
        let v = AdjustedTextView(glyphShift: 5, caretShift: 0)
        v.backgroundColor = UIColor(white: 1, alpha: 0.08)
        v.layer.cornerRadius = 16
        v.textColor = .white
        v.font = UIFont(name: "TTCommons-DemiBold", size: 28)
        v.textContainerInset = .init(top: 10, left: 14, bottom: 10, right: 14)
        v.isScrollEnabled = false
        v.keyboardAppearance = .dark
        v.returnKeyType = .done
        v.autocorrectionType = .no
        v.autocapitalizationType = .sentences
        return v
    }()
    private let placeholder = AdjustedLabel(verticalShift: 5)
    private var onChange: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        configureTV()
        configurePlaceholder()
        
    }
    
    private func configureTV() {
        addSubview(tv)
        tv.pinTop(topAnchor, 4)
        tv.pinBottom(bottomAnchor, 4)
        tv.pinLeft(leadingAnchor, 0)
        tv.pinRight(trailingAnchor, 0)
        
        tv.delegate = self
    }
    
    private func configurePlaceholder() {
        placeholder.textColor = UIColor(white: 1, alpha: 0.35)
        placeholder.font = UIFont(name: "TTCommons-DemiBold", size: 28)
        addSubview(placeholder)
        
        placeholder.pinTop(tv.topAnchor, 10)
        placeholder.pinLeft(tv.leadingAnchor, 17)
        NSLayoutConstraint.activate([
            placeholder.trailingAnchor.constraint(lessThanOrEqualTo: tv.trailingAnchor, constant: -14)
        ])
        
    }

    func configure(text: String, placeholder: String, onChange: @escaping (String) -> Void) {
        self.onChange = onChange
        tv.text = text
        self.placeholder.text = placeholder
        self.placeholder.isHidden = !text.isEmpty
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
        onChange?(textView.text)
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        layoutIfNeeded()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" { textView.resignFirstResponder(); return false }
        return true
    }
}
