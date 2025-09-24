//
//  TestNumberCell.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

// MARK: - Cell
final class TestNumberCell: UICollectionViewCell {
    static let reuseID = "TestNumberCell"
    private var hasAnswer: Bool = false

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Colors.textPrimary
        label.sizeToFit()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Colors.surfaceSecondary
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.addSubview(numberLabel)
        numberLabel.pinCenterX(contentView.centerXAnchor)
        numberLabel.pinCenterY(contentView.centerYAnchor, 3)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet { updateSelectionAppearance() }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        hasAnswer = false
        numberLabel.text = nil
        updateBackground()
    }

    func configure(number: Int, selected: Bool, hasAnswer: Bool) {
        numberLabel.text = "\(number)"
        self.hasAnswer = hasAnswer
        isSelected = selected
        updateBackground()
    }

    func setHasAnswer(_ value: Bool) {
        hasAnswer = value
        updateBackground()
    }

    private func updateBackground() {
        contentView.backgroundColor = hasAnswer ? Colors.surfacePrimary : Colors.surfaceSecondary
    }

    private func updateSelectionAppearance() {
        if isSelected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = Colors.textPrimary.cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
    }
}
