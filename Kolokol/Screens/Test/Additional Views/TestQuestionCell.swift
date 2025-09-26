//
//  TestQuestionCell.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

final class TestQuestionCell: UITableViewCell {
    static let reuseID = "TestQuestionCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func hostLabel(_ label: UILabel, bottomPadding: CGFloat) {
        if label.superview !== contentView {
            label.removeFromSuperview()
            contentView.addSubview(label)
            label.pinTop(contentView.topAnchor, 0)
            label.pinLeft(contentView.leadingAnchor, 0)
            label.pinRight(contentView.trailingAnchor, 0)
            label.pinBottom(contentView.bottomAnchor, bottomPadding)
        }
    }
}
