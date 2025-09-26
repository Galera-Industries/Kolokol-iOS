//
//  DeadlineValueCell.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

final class DeadlineValueCell: UITableViewCell {
    static let reuseID = "DeadlineValueCell"
    
    private let label = UILabel()
    private var onTap: (() -> Void)?
    private var formatter: ((Date) -> String)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        configureUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        contentView.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        selectionStyle = .default
        
        configureLabel()
    }
    
    private func configureLabel() {
        label.textColor = .white
        label.font = UIFont(name: "TTCommons-DemiBold", size: 18)
        contentView.addSubview(label)
        
        label.pinTop(contentView.topAnchor, 10)
        label.pinBottom(contentView.bottomAnchor, 10)
        label.pinLeft(contentView.leadingAnchor, 20)
        label.pinRight(contentView.trailingAnchor, 20)
    }
    
    func configure(date: Date?, onTap: @escaping () -> Void, formatter: @escaping (Date) -> String) {
        self.onTap = onTap
        self.formatter = formatter
        update(date: date)
    }
    
    func update(date: Date?) {
        if let d = date, let fmt = formatter {
            label.text = fmt(d)
            label.textColor = .white
        } else {
            label.text = "Выбрать дату"
            label.textColor = .white
        }
    }
    
    @objc private func tapCell() { onTap?() }
}
