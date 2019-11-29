//
//  InAppWebViewOptions.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 21/10/18.
//

import Foundation
import WebKit

@objcMembers
public class InAppWebViewOptions: Options {
    
    var useShouldOverrideUrlLoading = false
    var useOnLoadResource = false
    var useOnDownloadStart = false
    var useOnTargetBlank = false
    var clearCache = false
    var userAgent = ""
    var applicationNameForUserAgent = ""
    var javaScriptEnabled = true
    var debuggingEnabled = true
    var javaScriptCanOpenWindowsAutomatically = false
    var mediaPlaybackRequiresUserGesture = true
    var verticalScrollBarEnabled = true
    var horizontalScrollBarEnabled = true
    var resourceCustomSchemes: [String] = []
    var contentBlockers: [[String: [String : Any]]] = []
    var minimumFontSize = 0
    var useShouldInterceptAjaxRequest = false
    var useShouldInterceptFetchRequest = false
    var incognito = false
    var cacheEnabled = true
    var transparentBackground = false
    var disableVerticalScroll = false
    var disableHorizontalScroll = false

    var disallowOverScroll = false
    var enableViewportScale = false
    var suppressesIncrementalRendering = false
    var allowsAirPlayForMediaPlayback = true
    var allowsBackForwardNavigationGestures = true
    var allowsLinkPreview = true
    var ignoresViewportScaleLimits = false
    var allowsInlineMediaPlayback = false
    var allowsPictureInPictureMediaPlayback = true
    var isFraudulentWebsiteWarningEnabled = true;
    var selectionGranularity = 0;
    var dataDetectorTypes: [String] = ["NONE"] // WKDataDetectorTypeNone
    var preferredContentMode = 0
    var sharedCookiesEnabled = false
    
    override init(){
        super.init()
    }
    
}


