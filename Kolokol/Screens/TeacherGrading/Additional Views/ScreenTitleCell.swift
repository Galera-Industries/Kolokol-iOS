import UIKit

final class ScreenTitleCell: UITableViewCell {
    static let reuseID = "ScreenTitleCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.ttCommonsDemiBold(40)
        label.textColor = Colors.textPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
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
