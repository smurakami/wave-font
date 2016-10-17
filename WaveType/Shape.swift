//
//  Path.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/15.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa
import CoreGraphics

class Shape {
    var points = [NSPoint]()
    var counter = 0
    
    var inner = [NSPoint]()
    
    init() {
        let resolution = 250
        points = (0..<resolution).map {
            i in
            let radian = CGFloat(i) * CGFloat(M_PI * 2) / CGFloat(resolution)
            let origin = NSPoint(x: 0.5, y: 0.5)
            let radius: CGFloat = 0.3
            return NSPoint(x: cos(radian), y: sin(radian)) * radius + origin
        }
        
        inner = (0..<resolution).map {
            i in
            let radian = CGFloat(i) * CGFloat(M_PI * 2) / CGFloat(resolution)
            let origin = NSPoint(x: 0.5, y: 0.5)
            let radius: CGFloat = 0.2
            return NSPoint(x: cos(radian), y: sin(radian)) * radius + origin
        }
    }
    
    func draw(in rect: NSRect, with wave: [Float]) {
        guard wave.count > 0 else { return }
        
        let colors = [
            NSColor.red,
            NSColor.green,
            NSColor.blue,
        ]
        
        guard let context = NSGraphicsContext.current() else {
            print("failed to get context")
            return
        }
        
        for color in colors {
            context.compositingOperation = .plusDarker
        
            let path = NSBezierPath()
            var prev = (points.last ?? NSPoint()) * rect.size + rect.origin
            
            for (i, point) in points.enumerated() {
                let p = point * rect.size + rect.origin
                let val = wave[(i + counter * points.count) % wave.count] * Float(rect.size.width * 0.1)
                
                let diff = p - prev
                let norm = CGPoint(x: -diff.y, y: diff.x)
                if i == 0 {
                    path.move(to: p + norm * CGFloat(val))
                } else {
                    path.line(to: p + norm * CGFloat(val))
                }
                prev = p
            }
            path.close()
            
            color.set()
            path.fill()
            
            counter += 1
        }
        
        for color in colors {
        
            context.compositingOperation = .plusLighter
            
            let path = NSBezierPath()
            var prev = (inner.last ?? NSPoint()) * rect.size + rect.origin
            for (i, point) in inner.enumerated() {
                let p = point * rect.size + rect.origin
                let val = wave[(i + counter * points.count) % wave.count] * Float(rect.size.width * 0.1)
                
                let diff = p - prev
                let norm = CGPoint(x: -diff.y, y: diff.x)
                if i == 0 {
                    path.move(to: p + norm * CGFloat(val))
                } else {
                    path.line(to: p + norm * CGFloat(val))
                }
                prev = p
            }
            path.close()
            
            color.set()
            path.fill()
            
            counter += 1
        }
    }
}
