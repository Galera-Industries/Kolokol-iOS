//
//  AttemptProgressCell.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

final class AttemptProgressCell: UITableViewCell {
    static let reuseId = "AttemptCell"
    
    private let nameLabel = UILabel()
    private let progressView = StepProgressView(steps: 1)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.numberOfLines = 1
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(progressView)
        nameLabel.pinTop(contentView.topAnchor, 10)
        nameLabel.pinLeft(contentView.leadingAnchor, 20)
        progressView.pinLeft(contentView.leadingAnchor, 20)
        progressView.pinRight(contentView.trailingAnchor, 20)
        progressView.pinTop(nameLabel.bottomAnchor, 8)
    }
    
    func configure(fullName: String, answered: Int, total: Int, animated: Bool) {
        nameLabel.text = fullName
        progressView.setSteps(total)
        progressView.setCurrentStep(answered, animated: animated, allowRegression: false)
    }
}

