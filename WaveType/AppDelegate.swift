//
//  AppDelegate.swift
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/09.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var feeling: Float = 0.5
    var hue: CGFloat = 0
    var salutation: CGFloat = 1
    var brightness: CGFloat = 1
    
    var text: String = ""
    var resolution: Float = 1.0
    
    var gap: CGFloat = 1/3.0
    var waveSize: CGFloat = 0.03

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    static var shared: AppDelegate {
        get {
            return NSApplication.shared().delegate as! AppDelegate
        }
    }
}

