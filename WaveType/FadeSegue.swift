//
//  MyCustomSwiftSegue.swift
//  NSViewControllerPresentations
//
//  Created by jonathan on 25/01/2015.
//  Copyright (c) 2015 net.ellipsis. All rights reserved.
//

import Cocoa

class FadeSegue: NSStoryboardSegue, NSTableViewDelegate {
    
    override func perform() {
        let sourceVC  = self.sourceController as! NSViewController
        let destVC = self.destinationController as! NSViewController
        let animator = FadeSegueAnimator()
        sourceVC.presentViewController(destVC, animator: animator)
    }
}


