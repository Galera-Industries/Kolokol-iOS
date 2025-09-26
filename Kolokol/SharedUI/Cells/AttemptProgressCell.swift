//
//  AttemptProgressCell.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

final class AttemptProgressCell: UITableViewCell {
    static let reuseId = "AttemptCell"
    
    private let progressView = StepProgressView(steps: 1)
    private let nameLabel = AdjustedLabel()
    private let tgLabel = AdjustedLabel()
    private let resultLabel = AdjustedLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(progressView)
        progressView.setHeight(86)
        progressView.pinLeft(contentView.leadingAnchor, 20)
        progressView.pinRight(contentView.trailingAnchor, 20)
        progressView.pinTop(contentView.topAnchor, 4)
        progressView.pinBottom(contentView.bottomAnchor, 4)
        progressView.layer.cornerRadius = 32
        
        progressView.addSubview(nameLabel)
        nameLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        nameLabel.pinLeft(progressView.leadingAnchor, 24)
        nameLabel.pinTop(progressView.topAnchor, 22)
        nameLabel.textColor = .white
        
        progressView.addSubview(tgLabel)
        tgLabel.font = UIFont(name: "TTCommons-DemiBold", size: 18)
        tgLabel.textColor = Colors.textSecondary
        tgLabel.pinLeft(progressView.leadingAnchor, 24)
        tgLabel.pinTop(nameLabel.bottomAnchor, 3)
        
        progressView.addSubview(resultLabel)
        
        resultLabel.pinRight(progressView.trailingAnchor, 24)
        resultLabel.pinTop(progressView.topAnchor, 22)
        resultLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        resultLabel.textColor = .white
    }
    
    func configure(
        fullName: String,
        tg: String,
        answered: Int,
        total: Int,
        animated: Bool,
        assessed: Bool = false,
        result: Int? = nil
    ) {
        nameLabel.text = fullName
        tgLabel.text = tg
        if assessed {
            resultLabel.isHidden = false
        } else {
            resultLabel.isHidden = true
        }
        resultLabel.text = result?.description
        progressView.setSteps(total)
        progressView.setCurrentStep(answered, animated: animated, allowRegression: false)
    }
}
