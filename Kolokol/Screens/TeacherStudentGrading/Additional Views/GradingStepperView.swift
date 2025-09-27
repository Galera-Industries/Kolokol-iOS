import UIKit
import SwiftUI

// MARK: - GradingStepperView
final class GradingStepperView: UIView {

    var onChange: ((Int) -> Void)?

    private(set) var value: Int = 0 {
        didSet {
            updateValuePresentation(from: oldValue, to: value)
            updateButtonsVisibility()
            onChange?(value)
        }
    }

    func configureRange(min: Int = 0, max: Int = 10) {
        let newMin = min
        let newMax = Swift.max(max, newMin)
        minValue = newMin
        maxValue = newMax
        setValue(value, animated: false)
        updateButtonsVisibility()
    }

    func setValue(_ newValue: Int, animated: Bool) {
        let clamped = max(minValue, min(maxValue, newValue))
        guard clamped != value else { return }
        if animated {
            value = clamped
        } else {
            withoutAnimation {
                value = clamped
            }
        }
    }

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureActions()
        configureRange()
        updateButtonsVisibility()
        updateValuePresentation(from: value, to: value)

        backgroundColor = Colors.surfaceSecondary
        layer.cornerRadius = 32
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private: State
    private var minValue: Int = 0
    private var maxValue: Int = 10

    // MARK: Private: Subviews
    private let minusButton: UIButton = {
        let b = UIButton(type: .system)

        if let img = UIImage(systemName: "minus") {
            b.setImage(img, for: .normal)
        }
        b.tintColor = Colors.textSecondary
        return b
    }()

    private let plusButton: UIButton = {
        let b = UIButton(type: .system)

        if let img = UIImage(systemName: "plus") {
            b.setImage(img, for: .normal)
        }
        b.tintColor = Colors.textSecondary
        return b
    }()

    private let fallbackValueLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = Colors.textPrimary
        l.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        l.numberOfLines = 1
        l.isHidden = true
        return l
    }()

    private var hosting: UIHostingController<AnyView>?

    private func configureUI() {
        backgroundColor = .clear

        addSubview(minusButton)
        minusButton.setWidth(44)
        minusButton.setHeight(44)
        minusButton.pinLeft(leadingAnchor, 32)
        minusButton.pinCenterY(centerYAnchor)

        addSubview(plusButton)
        plusButton.setWidth(44)
        plusButton.setHeight(44)
        plusButton.pinRight(trailingAnchor, 32)
        plusButton.pinCenterY(centerYAnchor)

        if #available(iOS 17.0, *) {
            let hostingVC = UIHostingController(rootView: AnyView(NumericTextView(value: value)))
            hostingVC.view.backgroundColor = .clear
            hosting = hostingVC
            addSubview(hostingVC.view)
            hostingVC.view.pinCenterY(centerYAnchor)
            hostingVC.view.pinLeft(minusButton.trailingAnchor, 0)
            hostingVC.view.pinRight(plusButton.leadingAnchor, 0)

        } else {
            addSubview(fallbackValueLabel)
            fallbackValueLabel.pinCenterX(centerXAnchor)
            fallbackValueLabel.pinCenterY(centerYAnchor)
            fallbackValueLabel.isHidden = false
        }
    }

    private func configureActions() {
        minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc
    private func didTapMinus() {
        guard value > minValue else { return }
        setValue(value - 1, animated: true)
    }

    @objc
    private func didTapPlus() {
        guard value < maxValue else { return }
        setValue(value + 1, animated: true)
    }

    private func updateButtonsVisibility() {
        minusButton.isHidden = (value <= minValue)
        plusButton.isHidden  = (value >= maxValue)

        minusButton.isEnabled = !minusButton.isHidden
        plusButton.isEnabled  = !plusButton.isHidden
    }

    private func updateValuePresentation(from old: Int, to new: Int) {
        if #available(iOS 17.0, *) {
            hosting?.rootView = AnyView(NumericTextView(value: new))
        } else {
            let apply: () -> Void = { [weak self] in
                if let label = self?.fallbackValueLabel {
                    label.text = "\(new)"
                }
            }
            
            if window != nil {
                UIView.transition(with: fallbackValueLabel,
                                  duration: 0.15,
                                  options: .transitionCrossDissolve,
                                  animations: apply,
                                  completion: nil)
            } else {
                apply()
            }
        }
    }

    private func withoutAnimation(_ block: () -> Void) {
        UIView.performWithoutAnimation(block)
    }
}
