//
//  UIDeletableTextField.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import UIKit

final class UIDeletableTextField: UITextField {
    
    // MARK: - Constants
    private enum Constants {
        static let keyPath: String = "position"
        static let duration: CFTimeInterval = 0.09
        static let repeatCount: Float = 2
        static let shift: CGFloat = 3
        static let colorDuration: CFTimeInterval = 0.1
    }
    
    // MARK: - Override Delete Backward
    override public func deleteBackward() {
        super.deleteBackward()
        if let previousTextField = getPreviousTextField() {
            previousTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - Animation
    func shakeAndChangeColor() {
        let shakeAnimation = CABasicAnimation(keyPath: Constants.keyPath)
        shakeAnimation.duration = Constants.duration
        shakeAnimation.repeatCount = Constants.repeatCount
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - Constants.shift, y: self.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + Constants.shift, y: self.center.y))
        
        self.layer.add(shakeAnimation, forKey: Constants.keyPath)
        let originalColor = self.layer.borderColor
        UIView.animate(withDuration: Constants.colorDuration, animations: {
            self.layer.borderColor = originalColor
        }) { _ in
            UIView.animate(withDuration: Constants.colorDuration) {
                self.layer.borderColor = originalColor
            }
        }
    }
    
    // MARK: - Private methods
    private func getPreviousTextField() -> UITextField? {
        let currentTag = self.tag
        let previousTag = currentTag - 1
        return self.superview?.viewWithTag(previousTag) as? UITextField
    }
}
