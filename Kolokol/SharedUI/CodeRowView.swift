//
//  CodeRowView.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

final class CodeRowView: UIView {
    private let pill = UIView()
    private let codeLabel = AdjustedLabel(verticalShift: 3)
    private var onCopy: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func configureUI() {
        configurecodeLabel()
        configurePill()
        configureRow()
    }

    private func configurecodeLabel() {
        codeLabel.textAlignment = .center
        codeLabel.textColor = .white
        codeLabel.font = UIFont(name: "TTCommons-DemiBold", size: 22)
    }

    private func configurePill() {
        pill.backgroundColor = UIColor(white: 1, alpha: 0.08)
        pill.layer.cornerRadius = 14
        addSubview(pill)
        pill.setHeight(48)
        pill.pinTop(topAnchor, 4)
        pill.pinBottom(bottomAnchor, 4)
        pill.pinLeft(leadingAnchor, 0)
        pill.pinRight(trailingAnchor, 0)

        let tapCopy = UITapGestureRecognizer(target: self, action: #selector(tapCopyCode))
        pill.addGestureRecognizer(tapCopy)
        pill.isUserInteractionEnabled = true
    }

    private func configureRow() {
        let row = UIStackView(arrangedSubviews: [codeLabel])
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 8
        pill.addSubview(row)
        row.pinLeft(pill.leadingAnchor, 14)
        row.pinRight(pill.trailingAnchor, 8)
        row.pinCenterY(pill.centerYAnchor)
    }

    func configure(code: String, onRegenerate: @escaping () -> Void, onCopy: @escaping () -> Void) {
        self.onCopy = onCopy
        codeLabel.text = code
    }

    func setCode(_ code: String) {
        codeLabel.text = code
    }

    func setEnabled(_ enabled: Bool) {           // NEW
        pill.alpha = enabled ? 1.0 : 0.5
        pill.isUserInteractionEnabled = enabled
    }

    @objc private func tapCopyCode() { onCopy?() }
}
