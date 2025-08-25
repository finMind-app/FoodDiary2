//
//  ImageCache.swift
//  FoodDiaryTwo
//
//  Simple in-memory image cache for entry photos
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private init() {}
    private let cache = NSCache<NSString, UIImage>()
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}


