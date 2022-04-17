//
//  InAppWebViewOptions.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 21/10/18.
//

import Foundation
import WebKit

@objcMembers
public class InAppWebViewOptions: Options<InAppWebView> {
    
    var useShouldOverrideUrlLoading = false
    var useOnLoadResource = false
    var useOnDownloadStart = false
    var clearCache = false
    var userAgent = ""
    var applicationNameForUserAgent = ""
    var javaScriptEnabled = true
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
    var disableContextMenu = false
    var supportZoom = true
    var allowUniversalAccessFromFileURLs = false
    var allowFileAccessFromFileURLs = false

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
    var automaticallyAdjustsScrollIndicatorInsets = false
    var accessibilityIgnoresInvertColors = false
    var decelerationRate = "NORMAL" // UIScrollView.DecelerationRate.normal
    var alwaysBounceVertical = false
    var alwaysBounceHorizontal = false
    var scrollsToTop = true
    var isPagingEnabled = false
    var maximumZoomScale = 1.0
    var minimumZoomScale = 1.0
    var contentInsetAdjustmentBehavior = 2 // UIScrollView.ContentInsetAdjustmentBehavior.never
    var isDirectionalLockEnabled = false
    var mediaType: String? = nil
    var pageZoom = 1.0
    var limitsNavigationsToAppBoundDomains = false
    var useOnNavigationResponse = false
    var applePayAPIEnabled = false
    var allowingReadAccessTo: String? = nil
    var disableLongPressContextMenuOnLinks = false
    var disableInputAccessoryView = false
    
    override init(){
        super.init()
    }
    
    override func parse(options: [String: Any?]) -> InAppWebViewOptions {
        let _ = super.parse(options: options)
        if #available(iOS 13.0, *) {} else {
            applePayAPIEnabled = false
        }
        return self
    }
    
    override func getRealOptions(obj: InAppWebView?) -> [String: Any?] {
        var realOptions: [String: Any?] = toMap()
        if let webView = obj {
            let configuration = webView.configuration
            if #available(iOS 9.0, *) {
                realOptions["userAgent"] = webView.customUserAgent
                realOptions["applicationNameForUserAgent"] = configuration.applicationNameForUserAgent
                realOptions["allowsAirPlayForMediaPlayback"] = configuration.allowsAirPlayForMediaPlayback
                realOptions["allowsLinkPreview"] = webView.allowsLinkPreview
                realOptions["allowsPictureInPictureMediaPlayback"] = configuration.allowsPictureInPictureMediaPlayback
            }
            realOptions["javaScriptCanOpenWindowsAutomatically"] = configuration.preferences.javaScriptCanOpenWindowsAutomatically
            if #available(iOS 10.0, *) {
                realOptions["mediaPlaybackRequiresUserGesture"] = configuration.mediaTypesRequiringUserActionForPlayback == .all
                realOptions["ignoresViewportScaleLimits"] = configuration.ignoresViewportScaleLimits
                realOptions["dataDetectorTypes"] = Util.getDataDetectorTypeString(type: configuration.dataDetectorTypes)
            } else {
                realOptions["mediaPlaybackRequiresUserGesture"] = configuration.mediaPlaybackRequiresUserAction
            }
            realOptions["minimumFontSize"] = configuration.preferences.minimumFontSize
            realOptions["suppressesIncrementalRendering"] = configuration.suppressesIncrementalRendering
            realOptions["allowsBackForwardNavigationGestures"] = webView.allowsBackForwardNavigationGestures
            realOptions["allowsInlineMediaPlayback"] = configuration.allowsInlineMediaPlayback
            if #available(iOS 13.0, *) {
                realOptions["isFraudulentWebsiteWarningEnabled"] = configuration.preferences.isFraudulentWebsiteWarningEnabled
                realOptions["preferredContentMode"] = configuration.defaultWebpagePreferences.preferredContentMode.rawValue
                realOptions["automaticallyAdjustsScrollIndicatorInsets"] = webView.scrollView.automaticallyAdjustsScrollIndicatorInsets
            }
            realOptions["selectionGranularity"] = configuration.selectionGranularity.rawValue
            if #available(iOS 11.0, *) {
                realOptions["accessibilityIgnoresInvertColors"] = webView.accessibilityIgnoresInvertColors
                realOptions["contentInsetAdjustmentBehavior"] = webView.scrollView.contentInsetAdjustmentBehavior.rawValue
            }
            realOptions["decelerationRate"] = Util.getDecelerationRateString(type: webView.scrollView.decelerationRate)
            realOptions["alwaysBounceVertical"] = webView.scrollView.alwaysBounceVertical
            realOptions["alwaysBounceHorizontal"] = webView.scrollView.alwaysBounceHorizontal
            realOptions["scrollsToTop"] = webView.scrollView.scrollsToTop
            realOptions["isPagingEnabled"] = webView.scrollView.isPagingEnabled
            realOptions["maximumZoomScale"] = webView.scrollView.maximumZoomScale
            realOptions["minimumZoomScale"] = webView.scrollView.minimumZoomScale
            realOptions["allowUniversalAccessFromFileURLs"] = configuration.value(forKey: "allowUniversalAccessFromFileURLs")
            realOptions["allowFileAccessFromFileURLs"] = configuration.preferences.value(forKey: "allowFileAccessFromFileURLs")
            realOptions["isDirectionalLockEnabled"] = webView.scrollView.isDirectionalLockEnabled
            realOptions["javaScriptEnabled"] = configuration.preferences.javaScriptEnabled
            if #available(iOS 14.0, *) {
                realOptions["mediaType"] = webView.mediaType
                realOptions["pageZoom"] = Float(webView.pageZoom)
                realOptions["limitsNavigationsToAppBoundDomains"] = configuration.limitsNavigationsToAppBoundDomains
                realOptions["javaScriptEnabled"] = configuration.defaultWebpagePreferences.allowsContentJavaScript
            }
        }
        return realOptions
    }
}
