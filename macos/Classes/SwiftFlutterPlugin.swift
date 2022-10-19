/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

import FlutterMacOS
import AppKit
import WebKit
import Foundation
import AVFoundation
import SafariServices

public class SwiftFlutterPlugin: NSObject, FlutterPlugin {
    
    static var instance: SwiftFlutterPlugin?
    var registrar: FlutterPluginRegistrar?
    var platformUtil: PlatformUtil?
    var inAppWebViewStatic: InAppWebViewStatic?
    var myCookieManager: Any?
    var myWebStorageManager: MyWebStorageManager?
    var credentialDatabase: CredentialDatabase?
    var inAppBrowserManager: InAppBrowserManager?
    var headlessInAppWebViewManager: HeadlessInAppWebViewManager?
    var webAuthenticationSessionManager: WebAuthenticationSessionManager?
//    var printJobManager: PrintJobManager?
    
    var webViewControllers: [String: InAppBrowserWebViewController?] = [:]
    var safariViewControllers: [String: Any?] = [:]
    
    public init(with registrar: FlutterPluginRegistrar) {
        super.init()
        self.registrar = registrar
        registrar.register(FlutterWebViewFactory(registrar: registrar) as FlutterPlatformViewFactory, withId: FlutterWebViewFactory.VIEW_TYPE_ID)
        
        platformUtil = PlatformUtil(registrar: registrar)
        inAppBrowserManager = InAppBrowserManager(registrar: registrar)
        headlessInAppWebViewManager = HeadlessInAppWebViewManager(registrar: registrar)
        inAppWebViewStatic = InAppWebViewStatic(registrar: registrar)
        credentialDatabase = CredentialDatabase(registrar: registrar)
        if #available(macOS 10.13, *) {
            myCookieManager = MyCookieManager(registrar: registrar)
        }
        myWebStorageManager = MyWebStorageManager(registrar: registrar)
        webAuthenticationSessionManager = WebAuthenticationSessionManager(registrar: registrar)
//        printJobManager = PrintJobManager()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftFlutterPlugin.instance = SwiftFlutterPlugin(with: registrar)
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        platformUtil?.dispose()
        platformUtil = nil
        inAppBrowserManager?.dispose()
        inAppBrowserManager = nil
        headlessInAppWebViewManager?.dispose()
        headlessInAppWebViewManager = nil
        inAppWebViewStatic?.dispose()
        inAppWebViewStatic = nil
        credentialDatabase?.dispose()
        credentialDatabase = nil
        if #available(macOS 10.13, *) {
            (myCookieManager as! MyCookieManager?)?.dispose()
            myCookieManager = nil
        }
        myWebStorageManager?.dispose()
        myWebStorageManager = nil
        webAuthenticationSessionManager?.dispose()
        webAuthenticationSessionManager = nil
//        printJobManager?.dispose()
//        printJobManager = nil
    }
}
