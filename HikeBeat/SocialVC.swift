//
//  SocialVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 12/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class SocialVC: UIViewController, CAPSPageMenuDelegate {
    
    var pageMenu : CAPSPageMenu?
    
    @IBOutlet weak var subView: UIView!
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.greenColor()
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
//        var controller : UIViewController = UIViewController(nibName: "controllerNibName", bundle: nil)
//        controller.title = "SAMPLE TITLE"
//        controllerArray.append(controller)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let discoverVC = storyboard.instantiateViewControllerWithIdentifier("discover")
        discoverVC.title = "Discover"
//        let followsVC = storyboard.instantiateViewControllerWithIdentifier("MainTableViewController")
//        followsVC.title = "Journeys"
        let followNavVC = storyboard.instantiateViewControllerWithIdentifier("follows")
        followNavVC.title = "Follows"
        
        controllerArray.append(discoverVC)
//        controllerArray.append(followsVC)
        controllerArray.append(followNavVC)
        
        var font = UIFont.systemFontOfSize(23)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        var parameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(4.3),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorPercentageHeight(0.0),
            .MenuHeight(50),
            .ScrollMenuBackgroundColor(UIColor.greenColor()),
            .SelectionIndicatorColor(UIColor.whiteColor()),
            .ScrollAnimationDurationOnMenuItemTap(300),
            .AddBottomMenuHairline(true),
            .MenuItemFont(font)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.subView.addSubview(pageMenu!.view)
        
        pageMenu!.delegate = self
    }
    
    func willMoveToPage(controller: UIViewController, index: Int){}
    
    func didMoveToPage(controller: UIViewController, index: Int){}
}
