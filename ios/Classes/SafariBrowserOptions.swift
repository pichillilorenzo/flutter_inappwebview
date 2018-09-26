//
//  SafariBrowserOptions.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 26/09/18.
//

import Foundation

@objcMembers
public class SafariBrowserOptions: Options {
    
    var entersReaderIfAvailable = false
    var barCollapsingEnabled = false
    var dismissButtonStyle = 0 //done
    var preferredBarTintColor = ""
    var preferredControlTintColor = ""
    
    override init(){
        super.init()
    }
    
}
