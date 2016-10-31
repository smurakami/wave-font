//
//  TitleViewController.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/30.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class TitleViewController: NSViewController {
    
    var tuningImageView: NSImageView? = nil
    
    @IBOutlet weak var startButton: ImageButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        startButton.pushed = {
            [weak self] in
            self?.buttonPush()
        }
    }
    
    override func viewDidAppear() {
        print("title: view did appear")
        startButton.valid = true
    }
    
    override func viewDidDisappear() {
        tuningImageView?.removeFromSuperview()
        print("title: view did disappear")
    }
    
    func buttonPush() {
        startButton.valid = false
        let imageView = NSImageView(frame: view.bounds)
        imageView.image = NSImage(named: "ui_tuning")
        imageView.alphaValue = 0
        
        view.addSubview(imageView)
        
        NSAnimationContext.runAnimationGroup({
            context in
            context.duration = UI.transition
            imageView.animator().alphaValue = 1
            }, completionHandler: {
                Util.setTimeout(duration: 3, block: {
                    self.performSegue(withIdentifier: "next", sender: nil)
                })
        })
        
        tuningImageView = imageView
    }
}
