//
//  Util.swift
//  API Calling
//
//  Created by Sagar D. Bhut on 09/01/20.
//  Copyright © 2020 sdb. All rights reserved.
//

import UIKit
import Alamofire

class Util {

//Usage: check internet connection available or not
class func isConnectedToInternet() -> Bool {
    return NetworkReachabilityManager()!.isReachable
}

    class func parseValue(value : Any?) -> String {
        if let val = value as? Int {
            return "\(val)"
        } else if let val = value as? Double {
            return "\(val)"
        } else if let val = value as? String {
            return val
        }
        return "0"
    }
    
}
