//
//  DataManager.swift
//

import UIKit

struct Domain {
    //live
    static let ServiceUrl = "" //api url

    static let profile = ServiceUrl + "profile";
    
    
}

class Pagination {
    var current_page : Int
    var total_pages : Int
    var total : Int
    
    class func modelsFromDictionaryArray(array:NSArray) -> [Pagination] {
        var models:[Pagination] = []
        for item in array {
            models.append(Pagination(dictionary: item as? [String:Any] ?? [:])!)
        }
        return models
    }

    required public init?(dictionary: [String : Any]) {
        
        current_page = dictionary["current_page"] as? Int ?? 0
        total_pages = dictionary["total_pages"] as? Int ?? 0
        total = dictionary["total"] as? Int ?? 0
    }
}

class CarSubType {
    var sub_type_id : String
    var sub_type_name : String
    
    class func modelsFromDictionaryArray(array:[Any]) -> [CarSubType] {
        var models:[CarSubType] = []
        for item in array {
            models.append(CarSubType(dictionary: item as? [String: Any] ?? [:])!)
        }
        return models
    }
    
    required public init?(dictionary: [String: Any]) {
        
        sub_type_id = dictionary["sub_type_id"] as? String ?? ""
        sub_type_name = dictionary["sub_type_name"] as? String ?? ""
    }
}


class CarType {
    var car_type_id : String
    var car_type_name : String
    var service_sub_types : [CarSubType]
    
    class func modelsFromDictionaryArray(array: [Any]) -> [CarType] {
        var models:[CarType] = []
        for item in array {
            models.append(CarType(dictionary: item as? [String : Any] ?? [:])!)
        }
        return models
    }
    
    required public init?(dictionary: [String : Any]) {
        
        car_type_id = dictionary["car_type_id"] as? String ?? ""
        car_type_name = dictionary["car_type_name"] as? String ?? ""
        service_sub_types = CarSubType.modelsFromDictionaryArray(array: dictionary["service_sub_types"] as? [Any] ?? [])
    }
}

class PlaceList {
    public var pagination : Pagination
    public var status : Bool
    public var type : String
//    public var data : [Location]
    public var message : String
    public var response_code : Int
    
    public class func modelsFromDictionaryArray(array:[Any]) -> [PlaceList]
    {
        var models:[PlaceList] = []
        for item in array
        {
            models.append(PlaceList(dictionary: item as? [String: Any] ?? [:])!)
        }
        return models
    }
    required public init?(dictionary: [String:Any]) {
        
        pagination    = Pagination(dictionary: dictionary["pagination"] as? [String : Any] ?? [:])!
        status        = dictionary["status"] as? Bool ?? false
        type          = dictionary["type"] as? String ?? ""
//        data          = Location.modelsFromDictionaryArray(array : dictionary["data"] as? [Any] ?? [])
        message       = dictionary["message"] as? String ?? ""
        response_code = dictionary["response_code"] as? Int ?? 0
    }
}
