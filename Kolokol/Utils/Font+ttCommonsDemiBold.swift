//
//  Font+ttCommonsDemiBold.swift
//  Kolokol
//
//  Created by Арсений Потякин on 27.09.2025.
//

import UIKit

enum Font {
    static func ttCommonsDemiBold(_ size: CGFloat) -> UIFont {
        UIFont(name: "TTCommons-DemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }
}
