//
//  WaveManager.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/09.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa
import AVFoundation

class WaveManager: NSObject {
    
    var engine = AVAudioEngine()
    var callback: ((WaveManager) -> Void)?
    var wave: [Float] = []
    var power: [Float] = [] // 二乗積分値
    var player = AVAudioPlayerNode()
    var silencer = AVAudioMixerNode()
    var mode = Mode.input
    
    enum Mode {
        case input, file
    }
    
    override init() {
        super.init()
        
        silencer.outputVolume = 0
        engine.attach(silencer)
        engine.connect(silencer, to: engine.outputNode, format: nil)
        
        // get input
        guard let input = engine.inputNode else {
            print("could not find audio input")
            return
        }
        
        input.installTap(onBus: 0, bufferSize: 4096, format: input.inputFormat(forBus: 0)) {
            [weak self] (buffer, when) in
            if self?.mode != .input {
                return
            }
            
            let wave = (0..<Int(buffer.frameLength)).map { i in
                return buffer.floatChannelData![0][i]
            }
            
            var sum: Float = 0
            let power: [Float] = wave.map { val in
                sum += val * val
                return sum
            }
            
            self?.wave = wave
            self?.power = power
            
//            print(Analizer.shared.pitch(signal: wave))
            
            if let callback = self?.callback, let manager = self  {
                callback(manager)
            }
        }
        
        engine.attach(player)
        engine.connect(player, to: silencer, format: nil)
        
        player.installTap(onBus: 0, bufferSize: 4096, format: input.inputFormat(forBus: 0)) {
            [weak self] (buffer, when) in
            if self?.mode != .file {
                return
            }
            
            
            let wave = (0..<Int(buffer.frameLength)).map { i in
                return buffer.floatChannelData![0][i]
            }
            
            var sum: Float = 0
            let power: [Float] = wave.map { val in
                sum += val * val
                return sum
            }
            
            self?.wave = wave
            self?.power = power
            
            if let callback = self?.callback, let manager = self  {
                callback(manager)
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
    
    
    func play(url: URL) {
        let file = try! AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                      frameCapacity: UInt32(file.length))
        try! file.read(into: buffer)
        
        engine.connect(player, to: silencer, format: buffer.format)
        
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        player.play()
        
        mode = .file
    }
    
    static let shared = WaveManager()

}
