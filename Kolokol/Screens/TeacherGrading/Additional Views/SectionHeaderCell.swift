import UIKit

final class SectionHeaderCell: UITableViewCell {
    static let reuseID = "SectionHeaderCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.ttCommonsDemiBold(24)
        label.textColor = Colors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(titleLabel)
        configureConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func configure(title: String) { titleLabel.text = title }

    private func configureConstraints() {
        titleLabel.pinLeft(contentView, 0)
        titleLabel.pinTop(contentView, 0)
        titleLabel.pinBottom(contentView, 0)
    }
}
