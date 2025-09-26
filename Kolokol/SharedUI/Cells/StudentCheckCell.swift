//
//  StudentCheckCell.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import UIKit

final class StudentCheckCell: UITableViewCell {
    static let reuseId = "StudentCheckCell"

    private let cardView = UIView()
    private let nameLabel = AdjustedLabel()
    private let tgLabel = AdjustedLabel()
    private let checkbox = UIImageView()
    private var isChecked = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground
        backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.pinLeft(contentView.leadingAnchor, 20)
        cardView.pinRight(contentView.trailingAnchor, 20)
        cardView.pinTop(contentView.topAnchor, 4)
        cardView.pinBottom(contentView.bottomAnchor, 4)
        cardView.layer.cornerRadius = 32
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.10)
            : UIColor(white: 0.0, alpha: 0.06)
        }

        cardView.addSubview(nameLabel)
        nameLabel.font = UIFont(name: "TTCommons-DemiBold", size: 20)
        nameLabel.textColor = .label
        nameLabel.pinLeft(cardView.leadingAnchor, 24)
        nameLabel.pinTop(cardView.topAnchor, 18)

        cardView.addSubview(tgLabel)
        tgLabel.font = UIFont(name: "TTCommons-DemiBold", size: 16)
        tgLabel.textColor = .secondaryLabel
        tgLabel.pinLeft(cardView.leadingAnchor, 24)
        tgLabel.pinTop(nameLabel.bottomAnchor, 4)
        tgLabel.pinBottom(cardView.bottomAnchor, 18)

        cardView.addSubview(checkbox)
        checkbox.contentMode = .scaleAspectFit
        checkbox.tintColor = .systemBlue
        checkbox.pinRight(cardView.trailingAnchor, 24)
        checkbox.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 24).isActive = true
        checkbox.heightAnchor.constraint(equalToConstant: 24).isActive = true

        updateCheckbox(animated: false)
    }

    private func updateCheckbox(animated: Bool) {
        let imgName = isChecked ? "checkmark.circle.fill" : "circle"
        let img = UIImage(systemName: imgName)?.withRenderingMode(.alwaysTemplate)
        let apply = { self.checkbox.image = img }
        if animated { UIView.transition(with: checkbox, duration: 0.15, options: .transitionCrossDissolve, animations: apply) }
        else { apply() }

        cardView.layer.borderWidth = isChecked ? 1.0 : 0.0
        cardView.layer.borderColor = UIColor.label.withAlphaComponent(0.15).cgColor
    }

    func configure(fullName: String, tg: String, checked: Bool) {
        nameLabel.text = fullName
        tgLabel.text = tg.isEmpty ? "—" : (tg.hasPrefix("@") ? tg : "@\(tg)")
        isChecked = checked
        updateCheckbox(animated: false)
    }

    func setChecked(_ newValue: Bool, animated: Bool) {
        guard isChecked != newValue else { return }
        isChecked = newValue
        updateCheckbox(animated: animated)
    }
}
