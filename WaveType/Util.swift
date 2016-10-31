//
//  Util.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/31.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class Util: NSObject {
    @discardableResult
    class func setTimeout(duration: TimeInterval, block: @escaping (() -> Void)) -> Timer {
        return Timer.scheduledTimer(timeInterval: duration, target: BlockOperation(block: block ), selector: #selector(BlockOperation.main), userInfo: nil, repeats: false)
    }
    
    @discardableResult
    class func setInterval(duration: TimeInterval, block: @escaping (() -> Void)) -> Timer {
        return Timer.scheduledTimer(timeInterval: duration, target: BlockOperation(block: block ), selector: #selector(BlockOperation.main), userInfo: nil, repeats: true)
    }
}
