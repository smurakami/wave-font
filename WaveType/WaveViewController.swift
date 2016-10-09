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
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

