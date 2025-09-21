//
//  StepProgressView.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

class StepProgressView: UIProgressView {
    private(set) var steps: Int
    private(set) var currentStep: Int = 0

    init(steps: Int) {
        self.steps = max(1, steps)
        super.init(frame: .zero)
        self.progress = 0.0
        self.trackTintColor = .lightGray
        self.progressTintColor = .systemBlue
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder: NSCoder) { fatalError() }

    override func setProgress(_ progress: Float, animated: Bool) {
        super.setProgress(progress, animated: animated)
        progressTintColor = progress >= 1.0 ? .systemGreen : .systemBlue
    }

    func increment() {
        setCurrentStep(currentStep + 1, animated: true, allowRegression: false)
    }

    func reset() {
        currentStep = 0
        setProgress(0.0, animated: false)
        progressTintColor = .systemBlue
    }

    func setSteps(_ steps: Int) {
        self.steps = max(1, steps)
        // пересчитать прогресс с учётом нового знаменателя
        applyProgress(animated: false)
    }

    func setCurrentStep(_ step: Int, animated: Bool, allowRegression: Bool = false) {
        let clamped = max(0, min(step, steps))
        if !allowRegression && clamped < currentStep { return } // ignore regress
        currentStep = clamped
        applyProgress(animated: animated)
    }

    private func applyProgress(animated: Bool) {
        let p = Float(currentStep) / Float(steps)
        super.setProgress(p, animated: animated)
        progressTintColor = p >= 1.0 ? .systemGreen : .systemBlue
    }
}
