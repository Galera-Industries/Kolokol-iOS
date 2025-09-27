import UIKit

final class SpacerCell: UITableViewCell {
    static let reuseID = "SpacerCell"

    private let spacer = UIView()
    private var heightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(spacer)
        spacer.pin(contentView, 0)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = spacer.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { nil }

    func configure(height: CGFloat) {
        heightConstraint.constant = height
    }
}
