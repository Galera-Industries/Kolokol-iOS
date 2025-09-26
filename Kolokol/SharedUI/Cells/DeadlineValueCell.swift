//
//  DeadlineValueCell.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

final class DeadlineValueCell: UITableViewCell {
    static let reuseID = "DeadlineValueCell"
    
    var onChange: ((Date) -> Void)?
    
    private let datePicker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .date
        p.preferredDatePickerStyle = .compact
        p.minimumDate = Date()
        p.tintColor = .white
        return p
    }()
    
    var date: Date? {
        get { finalizeDate() }
    }
    
    private let timePicker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .time
        p.preferredDatePickerStyle = .compact
        p.tintColor = .white
        return p
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(datePicker)
        contentView.addSubview(timePicker)
        
        datePicker.pinLeft(contentView.leadingAnchor, 20)
        datePicker.pinCenterY(contentView.centerYAnchor)
        
        timePicker.pinRight(contentView.trailingAnchor, 20)
        timePicker.pinCenterY(contentView.centerYAnchor)
        
        datePicker.addTarget(self, action: #selector(updateValue), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(updateValue), for: .valueChanged)
    }
    
    func update(date: Date?) {
        guard let date else { return }
        datePicker.date = date
        timePicker.date = date
    }
    
    @objc private func updateValue() {
        if let finalDate = finalizeDate() {
            onChange?(finalDate)
        }
    }
    
    func finalizeDate() -> Date? {
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.year, .month, .day], from: datePicker.date)
        let timeComponents = cal.dateComponents([.hour, .minute, .second], from: timePicker.date)
        
        var merged = DateComponents()
        merged.year = dateComponents.year
        merged.month = dateComponents.month
        merged.day = dateComponents.day
        merged.hour = timeComponents.hour
        merged.minute = timeComponents.minute
        merged.second = timeComponents.second
        
        if let finalDate = cal.date(from: merged) {
            return finalDate
        }
        return nil
    }
}
