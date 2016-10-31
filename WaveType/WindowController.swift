//
//  WindowController.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/09.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
    }
}

extension WindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared().terminate(NSApp.keyWindow!)
    }
}
