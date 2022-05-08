//
//  PermissionResponse.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 07/05/22.
//

import Foundation

public class PermissionResponse : NSObject {
    var resources: [String]
    var action: Int?
    
    public init(resources: [String], action: Int? = nil) {
        self.resources = resources
        self.action = action
    }
    
    public static func fromMap(map: [String:Any?]?) -> PermissionResponse? {
        guard let map = map else {
            return nil
        }
        let resources = map["resources"] as! [String]
        let action = map["action"] as? Int
        return PermissionResponse(resources: resources, action: action)
    }
}
