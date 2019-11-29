//
//  InAppBrowserOptions.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 17/09/18.
//

import Foundation

@objcMembers
public class InAppBrowserOptions: Options {
    
    var hidden = false
    var toolbarTop = true
    var toolbarTopBackgroundColor = ""
    var toolbarTopFixedTitle = ""
    var hideUrlBar = false
    
    var toolbarBottom = true
    var toolbarBottomBackgroundColor = ""
    var toolbarBottomTranslucent = true
    var closeButtonCaption = ""
    var closeButtonColor = ""
    var presentationStyle = 0 //fullscreen
    var transitionStyle = 0 //crossDissolve
    var spinner = true
    
    override init(){
        super.init()
    }
    
}

