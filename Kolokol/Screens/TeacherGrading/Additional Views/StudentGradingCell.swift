import UIKit

final class StudentGradingCell: UITableViewCell {
    static let reuseID = "StudentGradingCell"

    // MARK: - UI
    private let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let leftStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 2
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.ttCommonsDemiBold(24)
        label.textColor = Colors.textPrimary
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.ttCommonsDemiBold(18)
        label.textColor = Colors.textSecondary
        label.numberOfLines = 1
        return label
    }()

    private let rightLabel: UILabel = {
        let label = UILabel()
        label.font = Font.ttCommonsDemiBold(24)
        label.textColor = Colors.textPrimary
        label.textAlignment = .right
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = Colors.surfaceSecondary
        contentView.layer.cornerRadius = 32

        setupViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Methods

    func configure(name: String, mail: String, grade: String? = nil) {
        titleLabel.text = name
        subtitleLabel.text = mail

        if let grade = grade, !grade.isEmpty {
            rightLabel.isHidden = false
            rightLabel.text = grade
        } else {
            rightLabel.isHidden = true
            rightLabel.text = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rightLabel.isHidden = true
        rightLabel.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    // MARK: - Private Methods

    private func setupViews() {
        contentView.addSubview(contentContainer)
        contentContainer.addSubview(leftStack)
        contentContainer.addSubview(rightLabel)

        leftStack.addArrangedSubview(titleLabel)
        leftStack.addArrangedSubview(subtitleLabel)
    }

    func configureConstraints() {
        contentContainer.pinHorizontal(contentView, 0)
        contentContainer.pinCenterY(contentView)
        contentContainer.setHeight(86)

        leftStack.pinLeft(contentContainer, 24)
        leftStack.pinCenterY(contentContainer)

        rightLabel.pinRight(contentContainer, 24)
        rightLabel.pinCenterY(contentContainer)

        // Чтобы длинные левые тексты не наехали на правый лейбл
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(
            item: leftStack,
            attribute: .trailing,
            relatedBy: .lessThanOrEqual,
            toItem: rightLabel,
            attribute: .leading,
            multiplier: 1.0,
            constant: -12
        ).isActive = true
    }
}
