//
//  UIViewController+Background.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

extension UIViewController {
    func configureBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
}
