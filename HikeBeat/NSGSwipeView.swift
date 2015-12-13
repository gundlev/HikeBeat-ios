//
//  NSGSwipeView.swift
//  SwipeToAction
//
//  Created by Niklas Gundlev on 02/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class NSGSwipeView: UIView {
    
    private var initialCenterDragView: CGPoint!
    private var fullShadowLength: CGFloat!
    private var fullShadowCenterPoint: CGPoint!
    
    private var backgroundView: UIView!
    private var shadowView: UIView!
    private var dragView: UIView!
    var title: UILabel!
    private var gestureRecognizer: UIPanGestureRecognizer!
    internal var action = {
        print("No action set")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initializeViews() {
        self.backgroundColor = UIColor.clearColor()
        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        backgroundView.backgroundColor = UIColor.whiteColor()
        backgroundView.layer.cornerRadius = self.frame.height/2
        backgroundView.alpha = 0.5
        self.shadowView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
        shadowView.backgroundColor = UIColor.blueColor()
        shadowView.layer.cornerRadius = self.frame.height/2
        self.dragView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
        dragView.backgroundColor = UIColor.blueColor()
        dragView.layer.cornerRadius = self.frame.height/2
        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        dragView.addGestureRecognizer(self.gestureRecognizer)
        self.title = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
        self.title.layer.cornerRadius = self.frame.height/2
        self.title.textAlignment = .Center
        self.dragView.addSubview(self.title)
        
        self.addSubview(backgroundView)
        self.addSubview(shadowView)
        self.addSubview(dragView)
        
        self.initialCenterDragView = self.dragView.center
        self.fullShadowCenterPoint = self.backgroundView.center
        self.fullShadowLength = self.backgroundView.frame.width
        
    }
    
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self)
        
        if let localView = recognizer.view {
            if recognizer.state == UIGestureRecognizerState.Changed {
                // Check if its moving in the right direction to the right.
                if translation.x + localView.center.x >= initialCenterDragView.x {
                    //
                    if recognizer.locationOfTouch(0, inView: self).x < 0 + self.dragView.frame.width/2 {
                        self.setBack(false)
                    } else if translation.x > 0 || recognizer.locationOfTouch(0, inView: self).x < self.frame.width - self.dragView.frame.width/2 {
                    
                        if localView.center.x + translation.x <= (self.frame.width) - localView.frame.width/2 {
                            localView.center = CGPoint(x:localView.center.x + translation.x,
                                y:localView.center.y)
                            self.shadowView.frame.size.width = (shadowView.frame.size.width + translation.x)
                            self.shadowView.center = CGPoint(x: self.shadowView.center.x, y: self.shadowView.center.y)
                        } else if localView.center.x + translation.x > (self.frame.width) - localView.frame.width/2 {
                            localView.center = CGPoint(x:(self.frame.width) - localView.frame.width/2,
                                y:localView.center.y)
                            self.shadowView.frame.size.width = backgroundView.frame.width
                            self.shadowView.center = backgroundView.center
                        }
                    }
                
                } else {
                    self.setBack(false)
                }
                
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                print("Gesture ended")
                
                if localView.center.x == self.frame.width - localView.frame.width/2 {
                    self.action()
                } else {
                    self.setBack(true)
                }
            }
        }
        recognizer.setTranslation(CGPointZero, inView: self)
    }
    
    func setBack(animated: Bool) {
        let duration = NSTimeInterval(0.1)
        
        if animated {
            UIView.animateWithDuration(duration, animations: {
                self.dragView.center = self.initialCenterDragView
                self.shadowView.frame.size.width = self.shadowView.frame.size.height
                self.shadowView.center = self.initialCenterDragView
            })
        } else {
            self.dragView.center = self.initialCenterDragView
            self.shadowView.frame.size.width = self.shadowView.frame.size.height
            self.shadowView.center = self.initialCenterDragView
        }
    }
}
