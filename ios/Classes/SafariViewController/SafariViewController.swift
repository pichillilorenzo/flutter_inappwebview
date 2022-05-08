//
//  SafariViewController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 25/09/18.
//

import Foundation
import SafariServices

@available(iOS 9.0, *)
public class SafariViewController: SFSafariViewController, SFSafariViewControllerDelegate, Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_chromesafaribrowser_"
    var channelDelegate: SafariViewControllerChannelDelegate?
    var safariSettings: SafariBrowserSettings
    var id: String
    var menuItemList: [[String: Any]] = []
    
    @available(iOS 11.0, *)
    public init(id: String, url: URL, configuration: SFSafariViewController.Configuration, menuItemList: [[String: Any]] = [], safariSettings: SafariBrowserSettings) {
        self.id = id
        self.menuItemList = menuItemList
        self.safariSettings = safariSettings
        super.init(url: url, configuration: configuration)
        let channel = FlutterMethodChannel(name: SafariViewController.METHOD_CHANNEL_NAME_PREFIX + id,
                                           binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        self.channelDelegate = SafariViewControllerChannelDelegate(safariViewController: self, channel: channel)
        self.delegate = self
    }
    
    public init(id: String, url: URL, entersReaderIfAvailable: Bool, menuItemList: [[String: Any]] = [], safariSettings: SafariBrowserSettings) {
        self.id = id
        self.menuItemList = menuItemList
        self.safariSettings = safariSettings
        super.init(url: url, entersReaderIfAvailable: entersReaderIfAvailable)
        let channel = FlutterMethodChannel(name: SafariViewController.METHOD_CHANNEL_NAME_PREFIX + id,
                                           binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        self.channelDelegate = SafariViewControllerChannelDelegate(safariViewController: self, channel: channel)
        self.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        // prepareSafariBrowser()
        super.viewWillAppear(animated)
        channelDelegate?.onChromeSafariBrowserOpened()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        channelDelegate?.onChromeSafariBrowserClosed()
        self.dispose()
    }
    
    
    func prepareSafariBrowser() {
        if #available(iOS 11.0, *) {
            self.dismissButtonStyle = SFSafariViewController.DismissButtonStyle(rawValue: safariSettings.dismissButtonStyle)!
        }
        
        if #available(iOS 10.0, *) {
            if let preferredBarTintColor = safariSettings.preferredBarTintColor, !preferredBarTintColor.isEmpty {
                self.preferredBarTintColor = UIColor(hexString: preferredBarTintColor)
            }
            if let preferredControlTintColor = safariSettings.preferredControlTintColor, !preferredControlTintColor.isEmpty {
                self.preferredControlTintColor = UIColor(hexString: preferredControlTintColor)
            }
        }
        
        self.modalPresentationStyle = UIModalPresentationStyle(rawValue: safariSettings.presentationStyle)!
        self.modalTransitionStyle = UIModalTransitionStyle(rawValue: safariSettings.transitionStyle)!
    }
    
    func close(result: FlutterResult?) {
        dismiss(animated: true)
        
        // wait for the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {() -> Void in
            if let result = result {
               result(true)
            }
        })
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        close(result: nil)
    }
    
    public func safariViewController(_ controller: SFSafariViewController,
                              didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if didLoadSuccessfully {
            channelDelegate?.onChromeSafariBrowserCompletedInitialLoad()
        }
        else {
            print("Cant load successfully the 'SafariViewController'.")
        }
    }
    
    public func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        var uiActivities: [UIActivity] = []
        menuItemList.forEach { (menuItem) in
            let activity = CustomUIActivity(viewId: id, id: menuItem["id"] as! Int64, url: URL, title: title, label: menuItem["label"] as? String, type: nil, image: nil)
            uiActivities.append(activity)
        }
        return uiActivities
    }
//
//    public func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
//        print("excludedActivityTypesFor")
//        print(URL)
//        print(title)
//        return []
//    }
//
//    public func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
//        print("initialLoadDidRedirectTo")
//        print(URL)
//    }
    
    public func dispose() {
        channelDelegate?.dispose()
        channelDelegate = nil
        delegate = nil
        ChromeSafariBrowserManager.browsers[id] = nil
    }
    
    deinit {
        debugPrint("SafariViewController - dealloc")
        dispose()
    }
}
