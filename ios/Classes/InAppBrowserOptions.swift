//
//  InAppBrowserOptions.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 17/09/18.
//

import Foundation

@objcMembers
public class InAppBrowserOptions: Options {
    
    var useShouldOverrideUrlLoading = false
    var useOnLoadResource = false
    var openWithSystemBrowser = false;
    var clearCache = false
    var userAgent = ""
    var javaScriptEnabled = true
    var javaScriptCanOpenWindowsAutomatically = false
    var hidden = false
    var toolbarTop = true
    var toolbarTopBackgroundColor = ""
    var hideUrlBar = false
    var mediaPlaybackRequiresUserGesture = true
    var isLocalFile = false
    
    var disallowOverScroll = false
    var toolbarBottom = true
    var toolbarBottomBackgroundColor = ""
    var toolbarBottomTranslucent = true
    var closeButtonCaption = ""
    var closeButtonColor = ""
    var presentationStyle = 0 //fullscreen
    var transitionStyle = 0 //crossDissolve
    var enableViewportScale = false
    //var keyboardDisplayRequiresUserAction = true
    var suppressesIncrementalRendering = false
    var allowsAirPlayForMediaPlayback = true
    var allowsBackForwardNavigationGestures = true
    var allowsLinkPreview = true
    var ignoresViewportScaleLimits = false
    var allowsInlineMediaPlayback = false
    var allowsPictureInPictureMediaPlayback = true
    var spinner = true
    
    override init(){
        super.init()
    }
    
}

