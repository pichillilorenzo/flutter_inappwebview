//
//  InAppBrowserOptions.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 17/09/18.
//

import Foundation

@objcMembers
public class InAppBrowserSettings: ISettings<InAppBrowserWebViewController> {
    
    var hidden = false
    var hideToolbarTop = true
    var toolbarTopBackgroundColor: String?
    var hideUrlBar = false
    var hideProgressBar = false
    var toolbarTopFixedTitle: String?
    
    override init(){
        super.init()
    }
    
    override func getRealSettings(obj: InAppBrowserWebViewController?) -> [String: Any?] {
        var realOptions: [String: Any?] = toMap()
        if let inAppBrowserWebViewController = obj {
            realOptions["hidden"] = inAppBrowserWebViewController.isHidden
            realOptions["hideUrlBar"] = inAppBrowserWebViewController.window?.searchBar?.isHidden
            realOptions["progressBar"] = inAppBrowserWebViewController.progressBar.isHidden
            realOptions["hideToolbarTop"] = !(inAppBrowserWebViewController.window?.toolbar?.isVisible ?? true)
            realOptions["toolbarTopBackgroundColor"] = inAppBrowserWebViewController.window?.backgroundColor.hexString
        }
        return realOptions
    }
}
