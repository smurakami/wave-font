//
//  Path.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/15.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa
import CoreGraphics
//import SwiftyJSON

class Shape {
    var contour: Contour? = nil
    
    var counter = 0
    
    var contours_array: [[NSPoint]] = []
    var hierarchy: [[Int]] = []
    var size = NSSize()
    
    var resolution = 256 {
        didSet {
//            initPoints()
//            loadJSON()
            setupContours()
        }
    }
    
    var pitch: CGFloat = 0.003 // ポリゴン間のギャップ。1で正規化
    
    init() {
    }
    
    func load(contours contours_array: [[NSPoint]], hierarchy: [[Int]]) {
        self.contours_array = contours_array
        self.hierarchy = hierarchy
        
        setupContours()
    }
    
    func setupContours() {
        if contours_array.count == 0 {
            return
        }
        
        let flatten = contours_array.flatMap { $0 }
        let min_x = flatten.min { $0.x < $1.x }!.x
        let max_x = flatten.max { $0.x < $1.x }!.x
        let min_y = flatten.min { $0.y < $1.y }!.y
        let max_y = flatten.max { $0.y < $1.y }!.y
        
        // normalization
        let right = max_x + min_x
        let bottom = max_y + min_y
        let size = max(right, bottom)
        
        self.size = NSSize(width: right, height: bottom)
        
        let normalized = contours_array.map { contour in
            contour.map { point in point / size }
        }
        
        let filtered: [[NSPoint]] = normalized.map { contour in
            guard let first = contour.first else {
                return []
            }
            
            var current = first
            return [first] + contour.filter { point in
                if point.distanceTo(point: current) >= pitch {
                    current = point
                    return true
                } else {
                    return false
                }
            }
        }
        
        let contours = filtered.map { points in
            Contour(points: points)
        }
        
        for (index, h) in hierarchy.enumerated() {
            let contour = contours[index]
            contour.next = contours[safe: h[0]]
            contour.next?.fill = contour.fill
            contour.prev = contours[safe: h[1]]
            contour.child = contours[safe: h[2]]
            contour.child?.fill = !contour.fill
            contour.parent = contours[safe: h[3]]
        }
        
        self.contour = contours.filter { $0.prev == nil && $0.parent == nil }.first!
    }
    
    func initPoints() {
        let points: [NSPoint] = (0..<resolution).map {
            i in
            let radian = CGFloat(i) * CGFloat(M_PI * 2) / CGFloat(resolution)
            let origin = NSPoint(x: 0.5, y: 0.5)
            let radius: CGFloat = 0.3
            return NSPoint(x: cos(radian), y: sin(radian)) * radius + origin
        }
        
        let inner: [NSPoint] = (0..<resolution).map {
            i in
            let radian = CGFloat(i) * CGFloat(M_PI * 2) / CGFloat(resolution)
            let origin = NSPoint(x: 0.5, y: 0.5)
            let radius: CGFloat = 0.2
            return NSPoint(x: cos(radian), y: sin(radian)) * radius + origin
        }
        
        contour = Contour(points: points, fill: true)
        contour?.add(child: Contour(points: inner))
    }
    
    func draw(in rect: NSRect) {
        // vertical align
        let aspect = size.height / size.width
        let height = rect.size.width * aspect
        
        var r = rect
        r.origin.y += (rect.size.height - height)/2
        
        guard WaveManager.shared.wave.count > 0 else { return }
        contour?.draw(in: r)
    }
}
