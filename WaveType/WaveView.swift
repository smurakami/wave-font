//
//  WaveView.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/09.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class WaveView: NSView {
    var counter = 0
    var buffer: [Float] = [] { didSet { counter = 0 } }
    var resolution = 256
    var waveNum = 10
    var timer = Timer()
    let fps: TimeInterval = 60
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        timer.invalidate()
        timer = Timer()
    }
    
    func setup() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30, repeats: true) {
            [weak self] timer in
            self?.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // parameters
        let size = dirtyRect.size
        // Drawing code here.
        let path = NSBezierPath()
        
        if buffer.count > 0 {
            for index in 0..<resolution {
                let val = buffer[(index + resolution * counter) % buffer.count]
                let point = NSPoint(
                    x: size.width * CGFloat(index)/CGFloat(resolution),
                    y: CGFloat(0.5 * val) * size.height)
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.line(to: point)
                }
            }
        } else {
            let start = NSPoint(x: 0, y: size.height/2)
            let end = NSPoint(x: size.width, y: size.height/2)
            path.move(to: start)
            path.line(to: end)
        }
        
        // appearance
        NSColor.black.set()
        path.lineWidth = 1
        
        // stroke
        let height = size.height / CGFloat(waveNum)
        path.transform(using: AffineTransform(translationByX: 0, byY: -height/2))
        
        for _ in 0..<waveNum {
            path.transform(using: AffineTransform(translationByX: 0, byY: height))
            path.stroke()
        }
        
        
        counter += 1
    }
    
}
