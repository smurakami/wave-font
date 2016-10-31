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
    var wave: [Float] = [] { didSet { counter = 0 } }
    var power: [Float] = []
    var resolution: Int = 256 {
        didSet {
            shape.resolution = resolution
        }
    }
    
    var waveNum: Int = 1
    var timer: Timer? = nil
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
        stop()
    }
    
    func setup() {
        image = NSImage(named: "wave-font") ?? NSImage()
        timer = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    func start() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func update() {
        self.needsDisplay = true
    }
    
    func set(text: String, fontSize: CGFloat = 240) {
        let label = NSTextField(frame: bounds)
        label.alignment = .center
        
        let rate: CGFloat = 4
        
        label.frame.size.width *= rate
        label.frame.size.height *= rate
        
        label.stringValue = text
        label.font = NSFont(name: "mplus-2p-medium", size: fontSize * rate * 0.8)
        
        
        let image = label.toImage()
        
        set(image: image)
    }
    
    func set(image: NSImage) {
        let cv = OpenCV()
        let result = cv.scanImage(image) as! Array<Array<AnyObject>>
        
        let contours_ = result[0]
        let hierarchy_ = result[1]
        
        var contours: [[NSPoint]] = []
        for contour_ in contours_ {
            var contour: [NSPoint] = []
            guard let contour__ = contour_ as? Array<NSValue> else {
                continue
            }
            for point in contour__ {
                contour.append(point.pointValue)
            }
            contours.append(contour)
        }
        
        let hierarchy: [[Int]] = hierarchy_.map {
            elem_ in
            if let elem = elem_ as? [NSNumber] {
                return elem.map { $0.intValue }
            } else {
                return []
            }
        }
        
        load(contours: contours, hierarchy: hierarchy)
    }
    
    func load(contours contours_array: [[NSPoint]], hierarchy: [[Int]]) {
        shape.load(contours: contours_array, hierarchy: hierarchy)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        backgroundColor.set()
        NSRectFill(dirtyRect)
        
        shape.draw(in: dirtyRect)
        
        counter += 1
    }
    
    func drawWave(in dirtyRect: NSRect) {
        // parameters
        let size = dirtyRect.size
        // Drawing code here.
        let path = NSBezierPath()
        
        let power: Float
        if wave.count > 0 {
            var sum: Float = 0
            for index in 0..<resolution {
                let val = wave[(index + resolution * counter) % wave.count]
                sum += val ** 2
            }
            
            power = sum / Float(resolution)
            
            for index in 0..<resolution {
                let val = wave[(index + resolution * counter) % wave.count]
                
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
}
