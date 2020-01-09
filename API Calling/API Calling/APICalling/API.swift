//
//  API.swift
//

import UIKit

class API : NSObject {

    //AppDelegate object
    static var sharedAppDelegate: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    typealias array = [Any]
    typealias dictionary = [String:Any]
    typealias responseCode = String
    
    static func checkResponse(response : dictionary?) -> (code : responseCode, isSuccess: Bool, messasge: String, result: dictionary) {
        if let result = response {
            let code = Util.parseValue(value: result["response_code"])
            if code == "401" {
                //logout app
            }
            let status = result["status"] as? Bool ?? false
            let msg = result["message"] as? String ?? ""
            return (code, status, msg, result)
        } else {
            return ("404", false, "Data source not found", [:])
        }
    }
    
    private class func apiCalling(vc: UIViewController?, url : String, parameter: [String: Any], timeOut : TimeInterval? = nil, completion:@escaping (responseCode, Bool, String?, dictionary) -> Void) {
        print("======URL======\n\(url)\n=====PARAMETER=====")
        print(parameter.compactMap({"\($0.key) : \($0.value)"}).joined(separator: "\n"))
        print("============\n")
        
        if (Util.isConnectedToInternet()) {
            WebRequest.shared.parameterRequest(URL: url, parameters: parameter, timeOut: timeOut) { (array, dictionary, error) in
                guard error == nil else {
                    if WebRequest.shared.isForceCancelled {
                        print("====>Force cancelled")
                        WebRequest.shared.isForceCancelled = false
                        return
                    } else if (error as NSError?)?.code == NSURLErrorCancelled || (error as NSError?)?.code == NSURLErrorNetworkConnectionLost {
                        apiCalling(vc: vc, url: url, parameter: parameter, completion: completion)
                    } else if (error as NSError?)?.code == NSURLErrorTimedOut {
                        print("NSURLErrorTimedOut : \(UserData.timeOutCount)")
                        if UserData.timeOutCount < 2 {
                            UserData.timeOutCount = UserData.timeOutCount + 1
                            apiCalling(vc: vc, url: url, parameter: parameter, completion: completion)
                        } else {
                            UserData.timeOutCount = 0
                            completion("\(((error as NSError?)?.code ?? 404))", false, error?.localizedDescription ?? "", [:])
                        }
                    } else {
                        UserData.timeOutCount = 0
                        completion("\(((error as NSError?)?.code ?? 404))", false, error?.localizedDescription ?? "", [:])
                    }
                    return
                }
                
                UserData.timeOutCount = 0
                let response = API.checkResponse(response: dictionary)
                completion(response.code, response.isSuccess, response.messasge, response.result)
                print("Response : \(response.result)")
            }
        } else {
            UserData.timeOutCount = 0
            completion("100", false, "warning_no_internet", [:])
        }
    }
    
    private class func apiCallingWithImages(vc: UIViewController?, url: String, parameter: [String : Any], images : [UIImage], imageKeys : [String], isAttachment : Bool = false, fileKey : String = "", fileName : String = "", fileData : Data? = nil, timeOut : TimeInterval? = nil, completion:@escaping (responseCode, Bool, String?, dictionary) -> Void) {
        print("======URL======\n\(url)\n=====PARAMETER=====")
        print(parameter.compactMap({"\($0.key) : \($0.value)"}).joined(separator: "\n"))
        print("============\n")
        if (Util.isConnectedToInternet()) {
            WebRequest.shared.multipartRequest(url: url, image: images, imageKey: imageKeys, parameters: parameter, isAttachment: isAttachment, fileKey: fileKey, fileName: fileName, fileData: fileData, timeOut: timeOut) { (array, dictionary, error) in
                guard error == nil else {
                    if WebRequest.shared.isForceCancelled {
                        WebRequest.shared.isForceCancelled = false
                        return
                    } else if (error as NSError?)?.code == NSURLErrorCancelled || (error as NSError?)?.code == NSURLErrorNetworkConnectionLost {
                        apiCallingWithImages(vc: vc, url: url, parameter: parameter, images: images, imageKeys: imageKeys, isAttachment: isAttachment, fileKey: fileKey, fileName: fileName, fileData: fileData, completion: completion)
                    } else if (error as NSError?)?.code == NSURLErrorTimedOut {
                        print("NSURLErrorTimedOut : \(UserData.timeOutCount)")
                        if UserData.timeOutCount < 2 {
                            UserData.timeOutCount = UserData.timeOutCount + 1
                            apiCallingWithImages(vc: vc, url: url, parameter: parameter, images: images, imageKeys: imageKeys, isAttachment: isAttachment, fileKey: fileKey, fileName: fileName, fileData: fileData, completion: completion)
                        } else {
                            UserData.timeOutCount = 0
                            completion("\(((error as NSError?)?.code ?? 404))", false, error?.localizedDescription ?? "", [:])
                        }
                    } else {
                        UserData.timeOutCount = 0
                        completion("\(((error as NSError?)?.code ?? 404))", false, error?.localizedDescription ?? "", [:])
                    }
                    return
                }
                
                UserData.timeOutCount = 0
                let response = API.checkResponse(response: dictionary)
                completion(response.code, response.isSuccess, response.messasge, response.result)
                print("Response : \(response.result)")
            }
        } else {
            UserData.timeOutCount = 0
            completion("100", false, "warning_no_internet", [:])
        }
    }
    
    
    class func loginUser(vc: UIViewController?, userName : String, password: String, map_lat: String, map_long: String, deviceToken: String, userType : String, timeOut : TimeInterval? = nil, completion:@escaping (responseCode, Bool, String?, dictionary) -> Void ) {
        
        let parameter:[String:Any] = [
            "action": "login_customer",
            "contact_no": userName,
            "password": password,
            "device_token" : deviceToken,
            "user_type" : userType.uppercased(),
            "map_lat": map_lat,
            "map_long": map_long,
            "langId" : "lID",//UserData.shared.getLanguageId(),
            "device_type" : "ios"
        ]
        
        API.apiCalling(vc: vc, url: Domain.profile, parameter: parameter, timeOut: timeOut, completion: completion)
    }
    
    class func customerSignup(vc: UIViewController?, fName: String, lName: String, countryCode : String, contactNo : String, verifyId : String, email: String, password: String, otp : String, referralCode: String, completion:@escaping (responseCode, Bool, String?, dictionary) -> Void ) {
        
        let parameter:[String:Any] = [
            "action": "register_customer",
            "first_name" : fName,
            "last_name" : lName,
            "country_code" : countryCode,
            "contact_no" : contactNo,
            "verification_id" : verifyId,
            "verification_code" : otp,
            "email_id" : email,
            "password" : password,
            "referral_code" : referralCode,
            "langId" : "lId",//UserData.shared.getLanguageId(),
            "device_type" : "ios"
        ]
        
        API.apiCalling(vc: vc, url: Domain.profile, parameter: parameter, completion: completion)
    }

    
    
}
