//
//  Contour.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/27.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class Contour {
    var points = [NSPoint]()
    
    var next: Contour? = nil
    var prev: Contour? = nil
    var child: Contour? = nil
    var parent: Contour? = nil
    
    var fill = true
    var counter: Float = 0
    
    init(points: [NSPoint] = [], fill: Bool = true) {
        self.points = points
        self.fill = fill
    }
    
    func add(child cont: Contour) {
        if let child = self.child {
            var current = child
            while let next = current.next {
                current = next
            }
            current.next = cont
            cont.prev = current
        } else {
            child = cont
        }
        cont.fill = !fill
        cont.parent = self
    }
    
    func draw(in rect: NSRect) {
        let wave = WaveManager.shared.wave
        guard wave.count > 0 else { return }
        
        let waveSize = AppDelegate.shared.waveSize
        
        let size = max(rect.size.width, rect.size.height)
        
        let feeling = AppDelegate.shared.feeling
        
//        let hue = CGFloat((1 - feeling) * 244.0 / 340.0)
//        let salutation: CGFloat = 0.9
//        let brightness: CGFloat = 0.8
//        let gap: CGFloat = 0.25
        let hue = AppDelegate.shared.hue
        let salutation = AppDelegate.shared.salutation
        let brightness = AppDelegate.shared.brightness
        let gap = AppDelegate.shared.gap
        
        let alpha: CGFloat = 1.0
        
        func normalized(val: CGFloat) -> CGFloat {
            return val - floor(val)
        }
        
        let colors = [
            NSColor(calibratedHue: hue, saturation: salutation, brightness: brightness, alpha: alpha),
            NSColor(calibratedHue: normalized(val: hue + gap), saturation: salutation, brightness: brightness, alpha: alpha),
            NSColor(calibratedHue: normalized(val: hue - gap), saturation: salutation, brightness: brightness, alpha: alpha),
            NSColor.white,
            NSColor.black,
        ]
        
        guard let context = NSGraphicsContext.current() else {
            print("failed to get context")
            return
        }
        
        for color in colors {
            if fill {
                context.compositingOperation = .plusDarker
            } else {
                context.compositingOperation = .plusLighter
            }
        
            let path = NSBezierPath()
            var prev = (points.last ?? NSPoint()) * size + rect.origin
            
            var power: Float = 0
            
            var pathPos: Float = 0
            var wavePos: Float = 0
            while Int(pathPos) < points.count {
                let point = points[Int(pathPos)]
                let p = point * size + rect.origin
//                let a = wave[Int(floor(wavePos) + counter) % wave.count]
//                let b = wave[Int(ceil(wavePos) + counter) % wave.count]
//                let t = wavePos - floor(wavePos)
//                let _val = a + (a - b) * t
                let _val = wave[Int(wavePos + counter) % wave.count]
//                let val = _val * Float(size * waveSize)
                let val = Float(size) * Float(waveSize) * (1 - exp(-_val))
                
                power += _val ** 2
                
                let diff = p - prev
                let norm = CGPoint(x: -diff.y, y: diff.x).normalized()
                if pathPos == 0 {
                    path.move(to: p + norm * CGFloat(val))
                } else {
                    path.line(to: p + norm * CGFloat(val))
                }
                prev = p
                
                pathPos += 1
                wavePos += 1/AppDelegate.shared.resolution
            }
            path.close()
            
            path.transform(using: AffineTransform(scaleByX: 1, byY: -1))
            path.transform(using: AffineTransform(translationByX: 0, byY: rect.size.height))
            
            power /= Float(points.count)
            
            color.set()
            path.fill()
            
            counter += wavePos
        }
        
        child?.draw(in: rect)
        next?.draw(in: rect)
    }
    
}

