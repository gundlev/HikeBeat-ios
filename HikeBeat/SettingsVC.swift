//
//  SettingsVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 12/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: FormViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationAccessoryView.hidden = true
        
//        let stuff = ["one", "two", "three"]
        
        form +++= Section(header: "Settings", footer: " ")
            
            <<< SwitchRow() {
                $0.title = "Notifications"
                $0.value = true
                }.onChange({ (SwitchRow) -> () in
                    print("Value changed to: ", SwitchRow.value)
                })
        
            <<< ButtonRow("Logout") { row in
                row.title = row.tag
                row.presentationMode = .SegueName(segueName: "logout", completionCallback: nil)
                }
        
//            <<< TextRow("Slug") {
//                $0.title = $0.tag
//                $0.placeholder = "Climbing-Everest"
//            }
//            
//            <<< AlertRow<String>("Choose it!") {
//                $0.title = "AlertRow"
//                $0.selectorTitle = "Who is there?"
//                $0.options = stuff
//            }
            
//            <<< TextRow("Headline") {
//                $0.title = $0.tag
//                $0.placeholder = "My climb to the top of Mt. Everest"
//            }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "logout":
            print("Logout segue")
            
        default: print("Unknown Segue")
        }
    }
}