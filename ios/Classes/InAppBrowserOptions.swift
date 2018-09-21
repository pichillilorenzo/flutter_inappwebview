//
//  InAppBrowserOptions.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 17/09/18.
//

import Foundation

@objcMembers
public class InAppBrowserOptions: NSObject {
    
    var closeButtonCaption = ""
    var closeButtonColor = ""
    var clearCache = false
    var userAgent = ""
    var spinner = true
    var hidden = false
    var disallowOverScroll = false
    var toolbarTop = true
    var toolbarTopBackgroundColor = ""
    var toolbarTopTranslucent = true
    var toolbarBottom = true
    var toolbarBottomBackgroundColor = ""
    var toolbarBottomTranslucent = true
    var hideUrlBar = false
    var presentationStyle = 0 //fullscreen
    var transitionStyle = 0 //crossDissolve
    var enableViewportScale = false
    var keyboardDisplayRequiresUserAction = true
    var suppressesIncrementalRendering = false
    var allowsAirPlayForMediaPlayback = true
    var mediaTypesRequiringUserActionForPlayback = "none"
    var allowsBackForwardNavigationGestures = true
    var allowsLinkPreview = true
    var ignoresViewportScaleLimits = false
    var allowsInlineMediaPlayback = false
    var allowsPictureInPictureMediaPlayback = true
    var javaScriptCanOpenWindowsAutomatically = false
    var javaScriptEnabled = true
    
    override init(){
        super.init()
    }
    
    public func parse(options: [String: Any]) {
        for (key, value) in options {
            if self.value(forKey: key) != nil {
                self.setValue(value, forKey: key)
            }
        }
    }
}

