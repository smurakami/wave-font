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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let waveManager = WaveManager.shared
        waveManager.callback = {
            [unowned self] buffer in
        
            DispatchQueue.main.async {
                self.waveView.buffer = (0..<Int(buffer.frameLength)).map {
                    i in
                    return buffer.floatChannelData![0][i]
                }
            }
        }
        
        initParams()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // preferences
    
    func initParams() {
        waveNum = 1
        lineWidth = 1
        resolution = 256
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
    
    var resolution: Int = 256 {
        didSet {
            waveView.resolution = resolution
        }
    }

    var rotation: CGFloat = 0 {
        didSet {
            waveView.rotation = rotation * CGFloat(M_PI) / 180
        }
    }
}

