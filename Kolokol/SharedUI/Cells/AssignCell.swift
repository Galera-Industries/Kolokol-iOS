//
//  AssigneCell.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import UIKit

enum StudentSelection: Equatable {
    case all
    case some(Set<String>)
    
    var isAll: Bool {
        if case .all = self { return true } else { return false }
    }
    var ids: Set<String> {
        if case let .some(set) = self { return set } else { return [] }
    }
    static let none: StudentSelection = .some([])
}

final class AssignCell: UITableViewCell {
    static let reuseId = "AssignCell"

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private var onTap: (() -> Void)?

    struct ViewModel {
        let title: String
        let selection: StudentSelection
        let totalCount: Int
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(_ vm: ViewModel, onTap: @escaping () -> Void) {
        titleLabel.text = vm.title
        self.onTap = onTap


        if vm.selection.isAll {
            valueLabel.text = "Всем"
        } else {
            let count = vm.selection.ids.count
            if count == 0 {
                valueLabel.text = vm.totalCount > 0 ? "Не выбрано" : "Нет студентов"
            } else if count == vm.totalCount {
                valueLabel.text = "Всем"
            } else {
                valueLabel.text = "\(count) выбрано"
            }
        }
    }

    private func configureUI() {
        selectionStyle = .default
        backgroundColor = .clear

        titleLabel.font = UIFont(name: "TTCommons-DemiBold", size: 16)
        titleLabel.textColor = .label

        valueLabel.font = UIFont(name: "TTCommons-DemiBold", size: 16)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        contentView.addSubview(stack)
        
        stack.pinLeft(contentView.leadingAnchor, 20)
        stack.pinRight(contentView.trailingAnchor, 20)
        stack.pinTop(contentView.topAnchor, 12)
        stack.pinBottom(contentView.bottomAnchor, 12)
    }

    func handleTap() { onTap?() }
}
