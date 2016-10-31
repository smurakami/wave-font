//
//  ResultViewController.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/30.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class ResultViewController: NSViewController {

    @IBOutlet weak var waveView: WaveView!
    @IBOutlet weak var againButton: NSButton!
    @IBOutlet weak var backButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        for button in [againButton, backButton] {
            button?.wantsLayer = true
            button?.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
    
    override func viewWillAppear() {
        waveView.set(text: AppDelegate.shared.text, fontSize: 140)
        waveView.start()
    }
    
    override func viewDidDisappear() {
        waveView.stop()
    }
    
    @IBAction func againButtonPush(_ sender: NSButton) {
        dismiss(nil)
    }
    
    @IBAction func backButtonPush(_ sender: NSButton) {
        var current: NSViewController = self
        while let next = current.presenting {
            current.dismiss(nil)
            current = next
            
            if current.classForCoder == TitleViewController.self {
                break
            }
        }
        
    }
}
