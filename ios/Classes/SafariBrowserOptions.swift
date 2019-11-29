//
//  SafariBrowserOptions.swift
//  flutter_inappwebview
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
    var presentationStyle = 0 //fullscreen
    var transitionStyle = 0 //crossDissolve
    
    override init(){
        super.init()
    }
    
}
