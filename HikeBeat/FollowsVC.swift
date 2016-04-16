//
//  FollowsVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 18/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class FollowsVC: UIViewController {
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func search(sender: AnyObject) {
        
        let parameters = ["query": searchText.text!]
        
        print(IPAddress + "search")
//        Alamofire.request(.POST, IPAddress + "search", parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
//            print(response.result.value)
//        }
    }
    
}
