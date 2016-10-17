//
//  WaveView.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/09.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class WaveView: NSView {
    var counter: Int = 0
    var buffer: [Float] = [] { didSet { counter = 0 } }
    var resolution: Int = 256
    var waveNum: Int = 1
    var timer = Timer()
    var lineWidth: CGFloat = 1
    let fps: TimeInterval = 60
    var rotation: CGFloat = 0
    var backgroundColor: NSColor = NSColor.white
    var lineColor: NSColor = NSColor.black
    
    var image = NSImage()
    
    var shape = Shape()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        timer.invalidate()
        timer = Timer()
    }
    
    func setup() {
        image = NSImage(named: "wave-font") ?? NSImage()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30, repeats: true) {
            [weak self] timer in
            self?.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        backgroundColor.set()
        NSRectFill(dirtyRect)
        
//        drawWave(in: dirtyRect)
//        drawImage(dirtyRect)
        shape.draw(in: dirtyRect, with: buffer)
        
        counter += 1
    }
    
    func drawWave(in dirtyRect: NSRect) {
        // parameters
        let size = dirtyRect.size
        // Drawing code here.
        let path = NSBezierPath()
        
        let power: Float
        if buffer.count > 0 {
            var sum: Float = 0
            for index in 0..<resolution {
                let val = buffer[(index + resolution * counter) % buffer.count]
                sum += val ** 2
            }
            
            power = sum / Float(resolution)
            
            for index in 0..<resolution {
                let val = buffer[(index + resolution * counter) % buffer.count]
                
                let point = NSPoint(
                    x: size.width * CGFloat(index)/CGFloat(resolution - 1),
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
            power = 0
        }
        
        // appearance
//        lineColor.set()
        
        let hue = -CGFloat(log(power))/30.0
//        NSLog("%f", hue)
        NSColor(calibratedHue: hue, saturation: 1, brightness: 0.5, alpha: 1).set()
        
        path.lineWidth = lineWidth
        path.lineJoinStyle = .roundLineJoinStyle
        
        // Do any additional setup after loading the view.
        
        // stroke
        let height = size.height / CGFloat(waveNum)
        
        path.transform(using: AffineTransform(translationByX: 0, byY: -height/2))
        path.transform(using: AffineTransform(rotationByRadians: rotation))
        
        for _ in 0..<waveNum {
            let transform = AffineTransform(translationByX: 0, byY: height)
            path.transform(using: transform)
            path.stroke()
        }
        
    }
    
//    func drawImage(_ dirtyRect: NSRect) {
//        let scale = dirtyRect.width / image.size.width
//        let size = NSSize(width: image.size.width * scale, height: image.size.height * scale)
//        let rect = NSRect(
//            x: (dirtyRect.size.width - size.width)/2,
//            y: (dirtyRect.size.height - size.height)/2,
//            width: size.width,
//            height: size.height)
//        
//        image.draw(in: rect)
//    }
    
}
