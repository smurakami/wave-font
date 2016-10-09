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
    var step = 512
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
        let start = NSPoint(x: 0, y: size.height/2)
        let end = NSPoint(x: size.width, y: size.height/2)
        
        
        // Drawing code here.
        let path = NSBezierPath()
        path.move(to: start)
        
        if buffer.count > 0 {
            for index in 0..<step {
                let val = buffer[(index + step * counter) % buffer.count]
                path.line(to: NSPoint(
                    x: size.width * CGFloat(index)/CGFloat(step),
                    y: CGFloat(0.5 + 0.5 * val) * size.height
                ))
            }
        }
        
        path.line(to: end)
        
        // appearance
        path.stroke()
        NSColor.black.set()
        path.lineWidth = 1
        
        counter += 1
    }
    
}
