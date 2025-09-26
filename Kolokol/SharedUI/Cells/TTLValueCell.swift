//
//  TTLValueCell.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

final class TTLValueCell: UITableViewCell {
    static let reuseID = "TTLValueCell"

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont(name: "TTCommons-DemiBold", size: 18)
        l.text = "45 мин"
        return l
    }()
    private let stepper: UIStepper = {
        let s = UIStepper()
        s.minimumValue = 5
        s.maximumValue = 240
        s.stepValue = 5
        s.value = 45
        return s
    }()

    private var onTapCell: (() -> Void)?
    private var onStepper: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)

        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .default
        
        configureRow()
    }
    
    private func configureRow() {
        let row = UIStackView(arrangedSubviews: [valueLabel, UIView(), stepper])
        row.alignment = .center
        row.spacing = 12
        contentView.addSubview(row)
        
        row.pinTop(contentView.topAnchor, 6)
        row.pinBottom(contentView.bottomAnchor, 6)
        row.pinLeft(contentView.leadingAnchor, 20)
        row.pinRight(contentView.trailingAnchor, 20)
    }
    
    func configure(minutes: Int, onTapCell: @escaping () -> Void, onStepper: @escaping (Int) -> Void) {
        self.onTapCell = onTapCell
        self.onStepper = onStepper
        update(minutes: minutes)
    }

    func update(minutes: Int) {
        valueLabel.text = "\(minutes) мин"
        stepper.value = Double(minutes)
    }

    @objc private func tapCell(_ gr: UITapGestureRecognizer) {
        let point = gr.location(in: contentView)
        if stepper.frame.insetBy(dx: -8, dy: -8).contains(point) { return }
        onTapCell?()
    }

    @objc private func stepperChanged() {
        let val = Int(stepper.value)
        update(minutes: val)
        onStepper?(val)
    }
}

