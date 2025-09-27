//
//  DetailedCell.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import UIKit

final class DetailedCell: UITableViewCell  {
    
    static let reuse = "DetailedCell"
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let gradeLabel = PaddingLabel(padding: .init(top: 6, left: 10, bottom: 6, right: 10))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ review: Item) {
        titleLabel.text = review.text
        gradeLabel.text = "\(review.gotPoints)/\(review.maxPoints)"
    }

    private func setupUI() {
        container.backgroundColor = Colors.surfaceSecondary
        container.layer.cornerRadius = 18
        container.layer.masksToBounds = true
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = Colors.textPrimary
        titleLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        gradeLabel.textColor = .white
        gradeLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        gradeLabel.backgroundColor = .clear
        gradeLabel.layer.masksToBounds = true
        gradeLabel.setContentHuggingPriority(.required, for: .horizontal)
        gradeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(gradeLabel)
    }

    private func setupConstraints() {
        [container, titleLabel, gradeLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.widthAnchor.constraint(equalToConstant: 362),
            container.heightAnchor.constraint(equalToConstant: 85) // или равенство с contentView.heightAnchor
        ])

        // Внутренние
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),

            gradeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            gradeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: gradeLabel.leadingAnchor, constant: -12)
        ])
    }
}

final class PaddingLabel: UILabel {
    private let padding: UIEdgeInsets
    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}
