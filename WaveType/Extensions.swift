//
//  Extensions.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/27.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Foundation
import Cocoa

extension NSView {
    func toImage() -> NSImage {
        let rect = self.bounds
        let size = rect.size
        
        let bir = self.bitmapImageRepForCachingDisplay(in: rect)!
        
        bir.size = size
        cacheDisplay(in: rect, to: bir)
        
        let image = NSImage(size: size)
        image.addRepresentation(bir)
        return image
    }
}

extension NSImageView {
    func fade(image: NSImage?, duration: TimeInterval) {
        let view = NSImageView(frame: bounds)
        view.image = image
        view.alphaValue = 0
        
        addSubview(view)
        NSAnimationContext.runAnimationGroup({
            context in
                context.duration = duration
                view.animator().alphaValue = 1
            }, completionHandler: {
                self.image = image
                view.removeFromSuperview()
        })
    }
}

infix operator **
func **(left: Float, right: Float) -> Float {
    return powf(left, right)
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
