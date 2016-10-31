//
//  MyCustomSwiftAnimator.swift
//  NSViewControllerPresentations
//
//  Created by jonathan on 25/01/2015.
//  Copyright (c) 2015 net.ellipsis. All rights reserved.
//
//  based on:
//  http://stackoverflow.com/questions/26715636/animate-custom-presentation-of-viewcontroller-in-os-x-yosemite

import Cocoa

class FadeSegueAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    override init() {
        super.init()
    }
    
    @objc func  animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        topVC.view.alphaValue = 0
        bottomVC.view.addSubview(topVC.view)
        var frame : CGRect = NSRectToCGRect(bottomVC.view.frame)
        topVC.view.frame = NSRectFromCGRect(frame)
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = UI.transition
            topVC.view.animator().alphaValue = 1

            }, completionHandler: {
                completion in
                bottomVC.viewDidDisappear()
        })
        
    }
    
    
    @objc func  animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = UI.transition
            topVC.view.animator().alphaValue = 0
            }, completionHandler: {
                topVC.view.removeFromSuperview()
                bottomVC.viewDidAppear()
        })
    }

}
