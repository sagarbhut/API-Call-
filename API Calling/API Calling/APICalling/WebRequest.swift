//
//  WebRequest.swift
//
//

import UIKit
import Alamofire
import AlamofireImage

class WebRequest {
    
    static let shared = WebRequest()
    var isForceCancelled : Bool = false
    typealias array = [Any]
    typealias dictionary = [String:Any]
    //typealias images = UIImage
    
    var dataRequest : DataRequest!
    
    //API call only with URL
    func urlRequest(URL: String, completion:@escaping(dictionary?, array?, Error?) -> Void) {
    
        dataRequest = Alamofire.request(URL).validate(statusCode: 200..<300).responseJSON { response in
        
        switch(response.result) {
        case .failure(_):
            let error = response.result .error! as NSError?
            print("\(error?.localizedDescription ?? "")")
            completion(nil, nil, error)
        case .success(_) :
            if(response.result.value != nil) {
                if let dataArray = response.result.value as? [Any] {
                    completion(nil, dataArray, nil)
                } else if let dict = response.result.value as? [String : Any] {
                    completion(dict, nil, nil)
                } else {
                    completion(nil, nil, NSError(domain: "Could not connect to the server.", code: -1, userInfo: [:]))
                }
            }
        }
    }
}
    
    
    //API call with parameter
    func parameterRequest(URL:String, parameters:[String:Any], timeOut : TimeInterval? = nil, completion:@escaping (array?, dictionary?, Error?) -> Void)  {
        
        let manager = Alamofire.SessionManager.default
        if let timeOut = timeOut {
            manager.session.configuration.timeoutIntervalForRequest = timeOut
        }

        dataRequest  = manager.request(URL, method: HTTPMethod.post, parameters: parameters as Parameters).validate(statusCode: 200..<300).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
                
            case .success(_):
                if response.result.value != nil{
                    let data = response.result.value
                    if (data as? [Any]) != nil{
                        let dataarray = response.result.value as! [Any]
                        completion(dataarray, nil,nil)
                    } else if  (data as? [String:Any]) != nil {
                        let  dict = response.result.value as! [String:Any]
                        completion(nil, dict, nil)
                    } else{
                        completion(nil, nil, NSError(domain: "Could not connect to the server.", code: -1, userInfo: [:]))
                    }
                } else {
                    completion(nil, nil, NSError(domain: "Could not connect to the server.", code: -1, userInfo: [:]))
                }
            case .failure(_):
                if let error = response.result.error as NSError? {
                    print(error.localizedDescription)
                    //TODO: Display alert
                    completion(nil, nil, error)
                } else {
                    completion(nil, nil, NSError(domain: "Could not connect to the server.", code: -1, userInfo: [:]))
                }
            }
        }
    }
    
    //API call with multipart data
    func multipartRequest(url:String, image:[UIImage], imageKey:[String], parameters:[String:Any], isAttachment: Bool = false, fileKey: String = "", fileName: String = "", fileData: Data? = nil, timeOut : TimeInterval? = nil, completion:@escaping (array?, dictionary?, Error?) -> Void) {
        
        let manager = Alamofire.SessionManager.default
        if let timeOut = timeOut {
            manager.session.configuration.timeoutIntervalForRequest = timeOut
        } else {
            manager.session.configuration.timeoutIntervalForRequest = 120 //default 60 seconds
        }
        
        manager.upload(multipartFormData: { (mutiData) in
            for (key, value) in parameters {
                mutiData.append(((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!), withName: key)
            }
            for i in 0..<image.count {
                let img_name = "img_\(Date().timeIntervalSince1970).jpeg"
                print("\(imageKey[i]) = \(img_name)")
                
                mutiData.append(image[i].jpegData(compressionQuality: 1.0)!, withName: imageKey[i], fileName: img_name, mimeType: "image/jpeg")
            }
            
            if(isAttachment && fileData != nil) {
                mutiData.append(fileData!, withName: fileKey, fileName: fileName, mimeType: "")
            }
            
        }, usingThreshold: UInt64(), to: URL(string:url)!, method: .post, headers: nil) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    if response.result.value != nil{
                        let data = response.result.value
                        
                        if (data as? [Any]) != nil{
                            let dataarray = response.result.value as! [Any]
                            completion(dataarray, nil,nil)
                        } else if  (data as? [String:Any]) != nil{
                            let  dict = response.result.value as! [String:Any]
                            completion(nil, dict, nil)
                        } else {
                            completion(nil, nil, NSError(domain: "Could not connect to the server.", code: -1, userInfo: [:]))
                        }
                    } else{
                        completion(nil, nil, NSError(domain: "Could not connect to the server.", code: -1, userInfo: [:]))
                    }
                })
                break
            case .failure(let error):            
                if let error = error as NSError? {
                    print(error.localizedDescription)
                    //TODO: Display alert
                    completion(nil, nil, error)
                } else {
                    completion(nil, nil, NSError(domain: "Could not connect to the server.", code: -1, userInfo: [:]))
                }
            }
        }
    }
    
    
    open func cancelRequest() {
        if self.dataRequest != nil {
            
            self.isForceCancelled = true
            print("=========>Web cancelled")
            dataRequest.cancel()
        }
    }
}
