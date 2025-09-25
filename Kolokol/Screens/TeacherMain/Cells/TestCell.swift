//
//  TestCell.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import UIKit

final class TestCell: UITableViewCell {
    static let cellIdentifier: String = "TestCell"
    
    private let testLabel = UILabel()
    private let dateLabel = UILabel()
    private let taskStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(_ test: TestModel) {
        testLabel.text = test.title
        dateLabel.text = formatDate(test.createdAt)
    }
    
    func configureCell() {
        contentView.backgroundColor = Colors.surfacePrimary
        selectionStyle = .none
        configureTaskStackView()
        configureTodoLabel()
        configureDateLabel()
    }
    
    private func configureTaskStackView() {
        contentView.addSubview(taskStackView)
        taskStackView.axis = .vertical
        taskStackView.spacing = 4
        
        let topRow = UIStackView(arrangedSubviews: [testLabel, UIView(), dateLabel])
        topRow.axis = .horizontal
        topRow.alignment = .firstBaseline

        taskStackView.addArrangedSubview(topRow)
        
        taskStackView.pinTop(contentView.topAnchor, 12)
        taskStackView.pinBottom(contentView.bottomAnchor, 12)
        taskStackView.pinLeft(contentView.leadingAnchor, 16)
        taskStackView.pinRight(contentView.trailingAnchor, 16)
    }
    
    private func configureTodoLabel() {
        testLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        testLabel.textColor = Colors.textPrimary
        testLabel.numberOfLines = 0
        testLabel.adjustsFontSizeToFitWidth = true
        testLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        testLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func configureDateLabel() {
        dateLabel.font = UIFont(name: "TTCommons-DemiBold", size: 12)
        dateLabel.textColor = Colors.textPrimary
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }
        
        return dateFormatter.string(from: date)
    }
}
