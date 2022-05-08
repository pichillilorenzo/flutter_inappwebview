//
//  SafariViewControllerChannelDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 05/05/22.
//

import Foundation

public class SafariViewControllerChannelDelegate : ChannelDelegate {
    private weak var safariViewController: SafariViewController?
    
    public init(safariViewController: SafariViewController, channel: FlutterMethodChannel) {
        super.init(channel: channel)
        self.safariViewController = safariViewController
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "close":
                if let safariViewController = safariViewController {
                    safariViewController.close(result: result)
                } else {
                    result(false)
                }
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func onChromeSafariBrowserOpened() {
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onChromeSafariBrowserOpened", arguments: arguments)
    }
    
    public func onChromeSafariBrowserCompletedInitialLoad() {
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onChromeSafariBrowserCompletedInitialLoad", arguments: arguments)
    }
    
    public func onChromeSafariBrowserClosed() {
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onChromeSafariBrowserClosed", arguments: arguments)
    }
    
    public func onChromeSafariBrowserMenuItemActionPerform(id: Int64, url: URL, title: String?) {
        let arguments: [String: Any?] = [
            "id": id,
            "url": url.absoluteString,
            "title": title,
        ]
        channel?.invokeMethod("onChromeSafariBrowserMenuItemActionPerform", arguments: arguments)
    }
    
    public override func dispose() {
        super.dispose()
        safariViewController = nil
    }
    
    deinit {
        dispose()
    }
}
