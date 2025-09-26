//
//  UIButton+MainButton.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import UIKit

extension UIButton {
    func configureMainButton(with title: String) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(Colors.textPrimary, for: .normal)
        self.backgroundColor = Colors.surfacePrimary
        self.titleLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        self.layer.cornerRadius = 32
        self.setHeight(86)
        
        self.addTarget(
            nil,
            action: #selector(buttonTouchDown(_:)),
            for: .touchDown
        )
        self.addTarget(
            nil,
            action: #selector(buttonTouchUp(_:)),
            for: [.touchUpInside, .touchDragExit, .touchCancel]
        )
    }
    
    @objc
    private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseIn, .allowUserInteraction]
        ) {
            sender.transform = CGAffineTransform(
                scaleX: 0.95,
                y: 0.95
            )
        }
    }
    
    @objc
    private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            sender.transform = .identity
        }
    }
}
