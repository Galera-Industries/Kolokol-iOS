//
//  TestAnswerCell.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

final class TestAnswerCell: UITableViewCell, UITextViewDelegate {
    static let reuseID = "TestAnswerCell"

    let textView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        tv.setContentCompressionResistancePriority(.required, for: .vertical)
        tv.setContentHuggingPriority(.defaultLow, for: .vertical)
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Ваш ответ"
        l.textColor = Colors.textSecondary
        return l
    }()

    var onTextChange: ((String) -> Void)?
    var onHeightChange: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)

        textView.pinTop(contentView.topAnchor, 0)
        textView.pinLeft(contentView.leadingAnchor, 0)
        textView.pinRight(contentView.trailingAnchor, 0)
        textView.pinBottom(contentView.bottomAnchor, 0)

        placeholderLabel.pinTop(textView.topAnchor, 0)
        placeholderLabel.pinLeft(textView.leadingAnchor, 0)
        placeholderLabel.pinRight(textView.trailingAnchor, 0)
        placeholderLabel.pinBottom(textView.bottomAnchor, 0)

        textView.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(font: UIFont?, color: UIColor, alignment: NSTextAlignment, text: String?) {
        textView.font = font
        textView.textColor = color
        textView.textAlignment = alignment
        textView.text = text ?? ""
        placeholderLabel.font = font
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        onTextChange?(textView.text)
        onHeightChange?()
    }
}
