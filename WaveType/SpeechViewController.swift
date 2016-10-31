//
//  SpeechViewController.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/30.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class SpeechViewController: NSViewController {

    @IBOutlet weak var bgImageView: NSImageView!
    @IBOutlet weak var waveImageView: WaveView!
    @IBOutlet weak var iconView: NSImageView!
    
    var recorder = Recorder()
    let speechAPI = SpeechAPI()
    
    var speaking: Bool = false
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        waveImageView.set(image: NSImage(named: "circle") ?? NSImage())
    }
    
    override func viewDidAppear() {
        waveImageView.start()
        listen()
        Util.setTimeout(duration: 3) {
            self.bgImageView.fade(image: NSImage(named: "ui_recommend"), duration: UI.transition)
        }
    }
    
    func listen() {
        recorder = Recorder()
        recorder.start()
        
        WaveManager.shared.mode = .input
        
        Util.setTimeout(duration: 4, block: {
            self.recognize()
        })
        
        iconView.image = NSImage(named: "icon_mic")
        timer?.invalidate()
        
//        speaking = false
//        let threshold: Float = -10
//        WaveManager.shared.callback = {
//            [weak self] manager in
//            guard let last = manager.power.last else { return }
//            guard let speaking = self?.speaking else { return }
//            let power = log(last / Float(manager.power.count))
//            
//            if speaking {
//                if power < threshold {
//                    self?.recognize()
//                }
//            } else {
//                if power > threshold {
//                    self?.speaking = true
//                }
//            }
//        }
    }
    
    override func viewDidDisappear() {
        waveImageView.stop()
        iconView.image = NSImage(named: "icon_mic")
    }
    
    func recognize() {
        recorder.stop()
        
        speechAPI.recognize(recorder.url) {
            text in
            print(text)
            if text != "" {
                AppDelegate.shared.text = text
                Analyzer.shared.emotion(filepath: self.recorder.url.path)
                WaveManager.shared.play(url: self.recorder.url)
                self.performSegue(withIdentifier: "next", sender: nil)
            } else {
                self.listen()
            }
        
        }
        
        let names = [ "", "icon_load_1", "icon_load_2", "icon_load_3", ]
        var counter = 0
        timer = Util.setInterval(duration: 0.5, block: {
            [weak self] in
            self?.iconView.image = NSImage(named: names[counter % names.count])
            counter += 1
        })
        
    }
}
