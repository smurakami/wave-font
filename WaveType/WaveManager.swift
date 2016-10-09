//
//  WaveManager.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/09.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa
import AVFoundation

infix operator **
func **(left: Float, right: Float) -> Float {
    return powf(left, right)
}

class WaveManager: NSObject {
    
    var engine = AVAudioEngine()
    var callback: ((AVAudioPCMBuffer) -> Void)?
    
    override init() {
        super.init()
        
        // get input
        guard let input = engine.inputNode else {
            print("could not find audio input")
            return
        }
        
        input.installTap(onBus: 0, bufferSize: 4096, format: input.inputFormat(forBus: 0)) {
            [weak self] (buffer, when) in
            if let callback = self?.callback {
                callback(buffer)
            }
        }
        
        // start
        do {
            try engine.start()
        } catch {
            print("failed starting engine")
            return
        }
    }
    
    static let shared = WaveManager()

}
