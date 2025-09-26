//
//  HeaderView.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import UIKit

final class SectionHeaderView: UITableViewHeaderFooterView {
    let label = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .black
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = Colors.textPrimary
        contentView.addSubview(label)
        contentView.backgroundColor = .clear

        label.pinLeft(contentView.leadingAnchor, 16)
        label.pinRight(contentView.trailingAnchor, 16)
        label.pinBottom(contentView.bottomAnchor, 6)
        label.pinTop(contentView.topAnchor, 12)
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
