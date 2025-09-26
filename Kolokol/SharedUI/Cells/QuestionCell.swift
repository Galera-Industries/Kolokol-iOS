//
//  QuestionCell.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

// MARK: - Question Cell
final class QuestionCell: UITableViewCell {
    static let reuseID = "QuestionCell"

    private let titleLabel = UILabel()
    private let kindLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        configureLabels()
        configureStack()
    }
    
    private func configureLabels() {
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        kindLabel.textColor = UIColor(white: 1, alpha: 0.6)
        kindLabel.font = .systemFont(ofSize: 14, weight: .regular)

    }
    
    private func configureStack() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, kindLabel])
        stack.axis = .vertical
        stack.spacing = 4
        contentView.addSubview(stack)

        stack.pinTop(contentView.topAnchor, 12)
        stack.pinBottom(contentView.bottomAnchor, 12)
        stack.pinLeft(contentView.leadingAnchor, 20)
        stack.pinRight(contentView.trailingAnchor, 20)
    }

    func configure(with row: QuestionRow, index: Int) {
        titleLabel.text = "\(index). \(row.title)"
        kindLabel.text = row.kind
    }
}
