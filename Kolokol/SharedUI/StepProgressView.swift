//
//  StepProgressView.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

final class StepProgressView: UIView {
    private(set) var steps: Int = 1
    private(set) var currentStep: Int = 0
    
    var cornerRadius: CGFloat = 32 {
        didSet {
            trackView.layer.cornerRadius = cornerRadius
            fillView.layer.cornerRadius = cornerRadius
        }
    }
    var trackColor: UIColor = Colors.surfaceSecondary.withAlphaComponent(0.25) {
        didSet { trackView.backgroundColor = trackColor }
    }
    var fillColor: UIColor = Colors.surfaceSecondary.withAlphaComponent(0.15) {
        didSet { fillView.backgroundColor = fillColor }
    }
    
    private let trackView = UIView()
    private let fillView = UIView()
    private var fillWidthConstraint: NSLayoutConstraint?
    
    init(steps: Int) {
        super.init(frame: .zero)
        self.steps = max(1, steps)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        trackView.backgroundColor = trackColor
        fillView.backgroundColor = fillColor
        trackView.layer.cornerRadius = cornerRadius
        fillView.layer.cornerRadius = cornerRadius
        trackView.layer.masksToBounds = true
        fillView.layer.masksToBounds = true
        
        addSubview(trackView)
        trackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 86)
        ])
        
        trackView.addSubview(fillView)
        fillView.translatesAutoresizingMaskIntoConstraints = false
        fillWidthConstraint = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0)
        fillWidthConstraint?.priority = .defaultHigh
        
        guard let fillWidthConstraint = fillWidthConstraint else { return }
        NSLayoutConstraint.activate([
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            fillWidthConstraint
        ])
    }
    
    func setSteps(_ total: Int) {
        steps = max(1, total)
        setCurrentStep(currentStep, animated: false, allowRegression: true)
    }
    
    func setCurrentStep(_ current: Int, animated: Bool, allowRegression: Bool) {
        let clamped: Int
        if allowRegression {
            clamped = min(max(0, current), steps)
        } else {
            clamped = min(max(currentStep, current), steps)
        }
        currentStep = clamped
        
        let progress = CGFloat(clamped) / CGFloat(max(steps, 1))
        updateFillWidth(to: progress, animated: animated)
    }
    
    // MARK: Internal
    private func updateFillWidth(to progress: CGFloat, animated: Bool) {
        fillWidthConstraint?.isActive = false
        fillWidthConstraint = fillView.widthAnchor.constraint(
            equalTo: trackView.widthAnchor,
            multiplier: max(0, min(1, progress))
        )
        fillWidthConstraint?.isActive = true
        
        let animations = { self.layoutIfNeeded() }
        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: animations,
                completion: nil
            )
        } else {
            animations()
        }
    }
}
