//
//  SimpleViewController.swift
//  API Calling
//
//  Created by Sagar D. Bhut on 09/01/20.
//  Copyright © 2020 sdb. All rights reserved.
//

import UIKit

class SimpleViewController: UIViewController {

  class func initializeVC() -> SimpleViewController {
            return Storyboard.main.instantiateViewController(withIdentifier: SimpleViewController.identifier) as! SimpleViewController
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
        }

        @IBAction func btnClick(_ sender: UIButton) {
            
            API.loginUser(vc: self, userName: "sagar", password: "123", map_lat: "22.70", map_long: "70.22", deviceToken: "123", userType: "user") { (responseCode, sucess, message, response) in
                
    //            code
                
            }
            
        }
        

    }

