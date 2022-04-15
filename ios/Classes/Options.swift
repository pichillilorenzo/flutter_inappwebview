//
//  Options.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 26/09/18.
//

import Foundation

@objcMembers
public class Options<T>: NSObject {
    
    override init(){
        super.init()
    }
    
    func parse(options: [String: Any?]) -> Options {
        for (key, value) in options {
            if !(value is NSNull), value != nil, self.responds(to: Selector(key)) {
                self.setValue(value, forKey: key)
            }
        }
        return self
    }
    
    func toMap() -> [String: Any?] {
        var options: [String: Any?] = [:]
        var counts = UInt32();
        let properties = class_copyPropertyList(object_getClass(self), &counts);
        for i in 0..<counts {
            let property = properties?.advanced(by: Int(i)).pointee;
            
            let cName = property_getName(property!);
            let name = String(cString: cName)
            
            options[name] = self.value(forKey: name)
        }
        free(properties)
        return options
    }
    
    func getRealOptions(obj: T?) -> [String: Any?] {
        let realOptions: [String: Any?] = toMap()
        return realOptions
    }
}
