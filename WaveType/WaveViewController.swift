//
//  ViewController.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/09.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class WaveViewController: NSViewController {

    @IBOutlet weak var waveView: WaveView!
    @IBOutlet weak var hsbLabel: NSTextField!
    let speechAPI = SpeechAPI()
    let recorder = Recorder()
    
    var currentInfo = Analyzer.Info()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = WaveManager.shared
        
        initParams()
        updateHSBLabel()
    }
    
    override func viewDidAppear() {
        waveView.set(text: "こんにちは")
    }
    
    
    
    // speech api
    @IBAction func startButtonPush(_ sender: NSButton) {
        recorder.start()
    }
    
    @IBAction func finishButtonPush(_ sender: NSButton) {
        recorder.stop()
        
        speechAPI.recognize(recorder.url) {
            result in
            self.waveView.set(text: result)
            WaveManager.shared.play(url: self.recorder.url)
            
        }
        
        currentInfo = Analyzer.shared.analyzeFile(filepath: recorder.url.path)
        Analyzer.shared.emotion(info: currentInfo)
    }
    
    @IBAction func calibButtonPush(_ sender: NSButton) {
        Analyzer.shared.normal = currentInfo
    }
    
    // preferences
    
    @IBAction func hueSliderChange(_ sender: NSSlider) {
        AppDelegate.shared.hue = CGFloat(sender.floatValue)
        updateHSBLabel()
    }
    
    @IBAction func salutationSliderChange(_ sender: NSSlider) {
        AppDelegate.shared.salutation = CGFloat(sender.floatValue)
        updateHSBLabel()
    }
    
    @IBAction func brightnessSliderChange(_ sender: NSSlider) {
        AppDelegate.shared.brightness = CGFloat(sender.floatValue)
        updateHSBLabel()
    }
    
    func updateHSBLabel() {
        let h = AppDelegate.shared.hue
        let s = AppDelegate.shared.salutation
        let b = AppDelegate.shared.brightness
        hsbLabel.stringValue = String(format: "(%.2f, %.2f, %.2f)", arguments: [h, s, b])
    }
    
    func initParams() {
        waveNum = 1
        lineWidth = 1
        rotation = 0
    }
    
    var waveNum: Int = 1 {
        didSet {
            waveView.waveNum = waveNum
        }
    }
    
    var lineWidth: CGFloat = 1 {
        didSet {
            waveView.lineWidth = lineWidth
        }
        
    }
    
    var gap: CGFloat = 0.2 {
        didSet {
            AppDelegate.shared.gap = gap
        }
    }
    
    var resolution: Float = 1.0 {
        didSet {
            AppDelegate.shared.resolution = resolution
        }
    }

    var waveSize: CGFloat = 0.1 {
        didSet {
            AppDelegate.shared.waveSize = waveSize
        }
    }
    
    var rotation: CGFloat = 0 {
        didSet {
            waveView.rotation = rotation * CGFloat(M_PI) / 180
        }
    }
}

