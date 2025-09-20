//
//  ImageLoader.swift
//  olympguide
//
//  Created by Tom Tim on 21.02.2025.
//

import Foundation
import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    
    private var cache: [String: UIImage] = [:]
    
    private init() {}
    
    func loadImage(from urlString: String) async -> UIImage? {
        if let cachedImage = cache[urlString] {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                return nil
            }
            cache[urlString] = image
            return image
        } catch {
            return nil
        }
    }
}
