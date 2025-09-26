//
//  SwitchCell.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

// MARK: - Switch Cell
final class SwitchCell: UITableViewCell {
    static let reuseID = "SwitchCell"
    
    private let label = UILabel()
    private let sw = UISwitch()
    private var onChange: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
        
        sw.addTarget(self, action: #selector(changed), for: .valueChanged)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        configureLael()
        configureRow()
    }
    
    private func configureRow() {
        let row = UIStackView(arrangedSubviews: [label, UIView(), sw])
        row.alignment = .center
        contentView.addSubview(row)
        
        row.pinTop(contentView.topAnchor, 6)
        row.pinBottom(contentView.bottomAnchor, 6)
        row.pinLeft(contentView.leadingAnchor, 20)
        row.pinRight(contentView.trailingAnchor, 22)
    }
    
    private func configureLael() {
        label.textColor = UIColor(white: 1, alpha: 0.9)
        label.font = UIFont(name: "TTCommons-DemiBold", size: 16)
    }
    
    func configure(title: String, isOn: Bool, onChange: @escaping (Bool) -> Void) {
        label.text = title
        sw.isOn = isOn
        self.onChange = onChange
    }
    
    @objc private func changed() { onChange?(sw.isOn) }
}
