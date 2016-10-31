//
//  ImageButtonView.swift
//  Coemoji
//
//  Created by 村上晋太郎 on 2016/11/01.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import Cocoa

class ImageButtonView: NSImageView {
    var valid = true
    var pushed: (() -> Void)? = nil
    
    override func mouseDown(with event: NSEvent) {
        if !valid {
            return
        }
        if let p = pushed {
            p()
        }
    }
}
