//
//  Recorder.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/28.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa
import AVFoundation

class Recorder: NSObject {
    
    var url = URL(fileURLWithPath: "")
    var recorder: AVAudioRecorder? = nil
    static let samplingRate = 16000
    
    func makeFileURL() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        let filename = "coemoji_" + formatter.string(from: Date()) + ".wav"
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
//        let dir = URL(fileURLWithPath: "/Users/smurakami/Desktop")
        return dir.appendingPathComponent(filename)
    }
    
    func start() {
        self.url = makeFileURL()
        
        let settings = [
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
            AVSampleRateKey: NSNumber(value: Float(Recorder.samplingRate)),
            AVNumberOfChannelsKey: NSNumber(value: UInt(1)),
            AVLinearPCMBitDepthKey: NSNumber(value: UInt(16)),
        ]
        
        guard let recorder = try? AVAudioRecorder(url: url, settings: settings) else {
            print("cannnot make recorder")
            return
        }
        
        self.recorder = recorder
        
        recorder.prepareToRecord()
        recorder.record()
    }
    
    func stop() {
        self.recorder?.stop()
    }

}
