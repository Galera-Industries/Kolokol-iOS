//
//  SecureView.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import UIKit

private let _secureTextField = UITextField()
private weak var _captureCanvasView: UIView?

private func resolveCaptureCanvasView() -> UIView? {
    if let cached = _captureCanvasView { return cached }
    if _secureTextField.superview == nil {
        let container = UIView(frame: .zero)
        container.isHidden = true
        container.addSubview(_secureTextField)
    }
    _secureTextField.isSecureTextEntry = false
    _secureTextField.isSecureTextEntry = true

    let canvas = _secureTextField.subviews.first {
        NSStringFromClass(type(of: $0)).contains("LayoutCanvasView")
    }
    _captureCanvasView = canvas
    return canvas
}

public extension CALayer {
    func makeHiddenOnCapture() {
        guard let canvas = resolveCaptureCanvasView() else { return }
        let originalLayer = canvas.layer
        canvas.setValue(self, forKey: "layer")
        _secureTextField.isSecureTextEntry = false
        _secureTextField.isSecureTextEntry = true
        canvas.setValue(originalLayer, forKey: "layer")
    }
}

public extension UIView {
    func hideOnCapture() {
        layer.makeHiddenOnCapture()
    }
}


final class VisibleOnlyOnCaptureView: UIView {
    private let whiteView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        whiteView.backgroundColor = .white
        addSubview(whiteView)
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteView.leadingAnchor.constraint(equalTo: leadingAnchor),
            whiteView.trailingAnchor.constraint(equalTo: trailingAnchor),
            whiteView.topAnchor.constraint(equalTo: topAnchor),
            whiteView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        // Маска белым + скрываем саму маску на скрине
        layer.mask = whiteView.layer
        whiteView.layer.makeHiddenOnCapture()
    }
}
