//
//  ImageCache.swift
//  LifeInYou
//
//  Created by Roman on 28.04.2022.
//

import UIKit

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {}
}
