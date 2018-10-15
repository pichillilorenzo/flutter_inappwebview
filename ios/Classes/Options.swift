//
//  Options.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 26/09/18.
//

import Foundation

@objcMembers
public class Options: NSObject {
    
    override init(){
        super.init()
    }
    
    public func parse(options: [String: Any]) -> Options {
        for (key, value) in options {
            if self.responds(to: Selector(key)) {
                self.setValue(value, forKey: key)
            }
        }
        return self
    }
}

