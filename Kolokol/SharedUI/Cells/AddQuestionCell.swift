//
//  AddQuestionCell.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

// MARK: - Add Question Cell (крупная кнопка)
final class AddQuestionCell: UITableViewCell {
    static let reuseID = "AddQuestionCell"
    
    private let button: UIButton = {
        var cfg: UIButton.Configuration
        if #available(iOS 26.0, *) {
            cfg = .prominentClearGlass()
        } else {
            cfg = .filled()
            cfg.baseBackgroundColor = UIColor(white: 1, alpha: 0.08)
        }
        cfg.cornerStyle = .large
        cfg.attributedTitle = .init("Добавить вопрос", attributes: .init([
            .font: UIFont(name: "TTCommons-DemiBold", size: 16)
        ]))
        let b = UIButton(configuration: cfg)
        b.tintColor = .white
        b.layer.cornerRadius = 16
        b.layer.masksToBounds = true
        b.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        b.imageEdgeInsets = .init(top: 0, left: -6, bottom: 0, right: 6)
        return b
    }()
    private var onTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(button)
        
        button.pinTop(contentView.topAnchor, 6)
        button.pinBottom(contentView.bottomAnchor, 6)
        button.pinLeft(contentView.leadingAnchor, 20)
        button.pinRight(contentView.trailingAnchor, 20)
        button.setHeight(56)
        
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    func configure(onTap: @escaping () -> Void) { self.onTap = onTap }
    
    @objc private func tap() { onTap?() }
}
