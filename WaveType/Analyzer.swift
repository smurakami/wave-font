//
//  FFT.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/29.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa
import AVFoundation

class Analyzer: NSObject {
    // 音声情報
    struct Info {
        var pitch: Float = 0
        var power: Float = 0
        var intonation: Float = 0
        
        func toDict() -> [String: Any] {
            return [
                "pitch": NSNumber(value: pitch),
                "power": NSNumber(value: power),
                "intonation": NSNumber(value: intonation),
            ]
        }
        
        static func fromDict(_ dict: [String: Any]) -> Info {
            let pitch = (dict["pitch"] as? NSNumber ?? NSNumber()).floatValue
            let power = (dict["power"] as? NSNumber ?? NSNumber()).floatValue
            let intonation = (dict["intonation"] as? NSNumber ?? NSNumber()).floatValue
            return Info(pitch: pitch, power: power, intonation: intonation)
        }
    }
    
    var silence = Info()
    var normal = Info()
    
    override init() {
        super.init()
        
        normal = Info.fromDict( UserDefaults.standard.value(forKey: "normal") as? [String : Any?] ?? [:] )
        print(normal)
    }
    
    func convert<T>(length: Int, data: UnsafeMutablePointer<Float>, _: T.Type) -> [T] {
        let numItems = length/MemoryLayout<T>.stride
        let buffer = data.withMemoryRebound(to: T.self, capacity: numItems) {
            UnsafeBufferPointer(start: $0, count: numItems)
        }
        return Array(buffer)
    }
    
    func pitch(signal: [Float]) -> Float {
        let pointer = UnsafeMutablePointer<Float>.allocate(capacity: signal.count)
        pointer.initialize(from: signal)
        let val = FFT.pitch(pointer, length:Int32(signal.count))
        pointer.deallocate(capacity: signal.count)
        return val
    }
    
    func power(signal: [Float]) -> Float {
        return signal.map{ $0 * $0 }.reduce(Float(0), +) / Float(signal.count)
    }
    
    func intonation(signal: [Float]) -> Float {
        var sum: Float = 0
        let cumsum: [Float] = signal.map { val in
            sum += val * val
            return sum
        }
        
        let window = 1000
        
        let power: [Float] = (0..<(cumsum.count - window)).map {
            i in
            return (cumsum[i+window] - cumsum[i])/Float(window)
        }
        
        let mean = power.reduce(Float(0), +) / Float(power.count)
        let s = power.map {($0 - mean) ** 2}.reduce(Float(0), +) / Float(power.count)
        
        return s
    }
    
    func analyzeFile(filepath: String) -> Info {
        let audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: filepath))
        let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFile.processingFormat,
            frameCapacity: UInt32(audioFile.length))
        
        try! audioFile.read(into: buffer)
        
        let sample:[Float] = Array(UnsafeMutableBufferPointer(start:buffer.floatChannelData![0], count:Int(buffer.frameCapacity)))
        
        let pitch = self.pitch(signal: sample)
        let power = self.power(signal: sample)
        let intonation = self.intonation(signal: sample)
        
        print("pitch: \(pitch)")
        print("power: \(log(power))")
        print("intonation: \(log(intonation))")
        
        print("lengh: \(sample.count)")
        
        return Info(pitch: pitch, power: power, intonation: intonation)
    }
    
    enum Emotion {
        case normal, anger, sad, delight
    }
    
    func emotion(filepath: String) {
        let info = analyzeFile(filepath: filepath)
        emotion(info: info)
    }
    
    func emotion(info: Info) {
        print("pitch: \(normal.pitch), \(info.pitch)")
        print("power: \(log(normal.power)), \(log(info.power)))")
        print("intonation: \(log(normal.intonation)), \(log(info.intonation))")
        var emo = Emotion.normal
        
        var hue: CGFloat = 0
        var salutation: CGFloat = 1
        var brightness: CGFloat = 1
        var resolution: CGFloat = 0.5
        var gap: CGFloat = 1.0/3
        var waveSize: CGFloat = 0.03
        
        if log(info.power) > log(normal.power) + 1.2 {
            emo = .anger
            
//            怒り(0.0,1.0,1.0)
//            resolution 0.02
//            wavesize 0.2
//            gap 0.075
            
        } else if info.pitch > normal.pitch && info.power > normal.power {
            emo = .delight
            
//            楽しみ(0.23,1.0,1.0)
//            resolution 1
//            wavesize 0.3
//            gap 0.075
            
        } else if info.pitch < normal.pitch && info.power < normal.power {
            emo = .sad
            
//            (0.5,1.0,1.0)
//            resolution 2.0
//            wavesize 0.1
//            gap 0.075
        }
        
        emo = .sad
        
        switch emo {
        case .normal:
            break
        case .anger:
            hue = 0
            salutation = 1.0
            brightness = 1.0
            resolution = 0.4
            gap = 0.075
            waveSize = 0.02
            
            break
        case .sad:
            hue = 0.5
            salutation = 1.0
            brightness = 1.0
            resolution = 3.0
            gap = 0.075
            
            break
        case .delight:
            hue = 0.23
            salutation = 1.0
            brightness = 1.0
            resolution = 2.0
            gap = 0.075
            
            break
        }
        
        AppDelegate.shared.hue = hue
        AppDelegate.shared.salutation = salutation
        AppDelegate.shared.brightness = brightness
        AppDelegate.shared.resolution = Float(resolution)
        AppDelegate.shared.gap = gap
        AppDelegate.shared.waveSize = waveSize
        
        
        print(emo)
    }
    
    static let shared = Analyzer()
    
}
