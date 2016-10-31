//
//  CalibratiionViewController.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/30.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class CalibratiionViewController: NSViewController {

    @IBOutlet weak var countImageView: NSImageView!
    @IBOutlet weak var waveView: WaveView!
    var nextImageView: NSImageView? = nil
    
    var silenceRecorder = Recorder()
    var normalRecorder = Recorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        waveView.set(text: "こえもじ", fontSize: waveView.frame.size.height)
    }
    
    override func viewDidAppear() {
        print("calib: view did appear")
        waveView.start()
        beginCalibration()
    }
    
    func beginCalibration() {
        let interval: TimeInterval = 0.6
        let imageNames = [ "icon_time_1", "icon_time_2", "icon_time_3", "icon_time_4", "icon_time_5", ]
        
        Util.setTimeout(duration: interval) {
            self.silenceRecorder.start()
        }
        
        Util.setTimeout(duration: interval * 4) {
            self.silenceRecorder.stop()
        }
        
        for (i, name) in imageNames.enumerated() {
            Util.setTimeout(duration: TimeInterval(i) * interval) {
                self.countImageView.image = NSImage(named: name)
            }
        }
        
        let current = interval * TimeInterval(imageNames.count - 1)
        Util.setTimeout(duration: current) {
            self.normalRecorder.start()
            
            Util.setTimeout(duration: 4, block: {
                self.endCalibration()
            })
        }
        
    }
    
    func endCalibration() {
        WaveManager.shared.callback = nil
        self.normalRecorder.stop()
        
        let normal = Analyzer.shared.analyzeFile(filepath: normalRecorder.url.path)
        print(normal.power)
        if log(normal.power) < -10 {
            again()
        } else {
            Analyzer.shared.normal = normal
            UserDefaults.standard.set(normal.toDict(), forKey: "normal")
            next()
        }
    }
    
    func again() {
        let imageView = NSImageView(frame: view.bounds)
        imageView.image = NSImage(named: "ui_sorry")
        
        imageView.alphaValue = 0
        
        view.addSubview(imageView)
        
        NSAnimationContext.runAnimationGroup({
            context in
            context.duration = UI.transition
            imageView.animator().alphaValue = 1
            }, completionHandler: {
                self.countImageView.image = NSImage(named: "icon_time_1")
                Util.setTimeout(duration: 3, block: {
                    NSAnimationContext.runAnimationGroup({
                        context in
                        context.duration = UI.transition
                        imageView.animator().alphaValue = 0
                        }, completionHandler: {
                            self.beginCalibration()
                    })
                })
        })
    }
    
    override func viewDidDisappear() {
        print("calib: view did disappear")
        waveView.stop()
    }
    
    func next() {
        let imageView = NSImageView(frame: view.bounds)
        imageView.image = NSImage(named: "ui_thankyou")
        imageView.alphaValue = 0
        
        view.addSubview(imageView)
        
        NSAnimationContext.runAnimationGroup({
            context in
            context.duration = UI.transition
            imageView.animator().alphaValue = 1
            }, completionHandler: {
                Util.setTimeout(duration: 3) {
                    self.performSegue(withIdentifier: "next", sender: nil)
                }
        })
    }
    
}
