import UIKit

final class TestAnswerLabelCell: UITableViewCell {
    static let reuseID = "TestAnswerLabelCell"

    private let answerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(answerLabel)
        answerLabel.pinTop(contentView.topAnchor, 0)
        answerLabel.pinLeft(contentView.leadingAnchor, 0)
        answerLabel.pinRight(contentView.trailingAnchor, 0)
        answerLabel.pinBottom(contentView.bottomAnchor, 0)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(font: UIFont?, color: UIColor, alignment: NSTextAlignment, text: String?) {
        answerLabel.font = font
        answerLabel.textColor = color
        answerLabel.textAlignment = alignment
        answerLabel.text = text ?? ""
    }
}
