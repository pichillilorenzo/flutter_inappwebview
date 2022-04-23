//
//  SafariViewController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 25/09/18.
//

import Foundation
import SafariServices

@available(iOS 9.0, *)
public class SafariViewController: SFSafariViewController, FlutterPlugin, SFSafariViewControllerDelegate {
    
    var channel: FlutterMethodChannel?
    var safariOptions: SafariBrowserOptions?
    var id: String = ""
    var menuItemList: [[String: Any]] = []
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    deinit {
        print("SafariViewController - dealloc")
        dispose()
    }
    
    public func prepareMethodChannel() {
        channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_chromesafaribrowser_" + id, binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        SwiftFlutterPlugin.instance!.registrar!.addMethodCallDelegate(self, channel: channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "close":
                close(result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        // prepareSafariBrowser()
        super.viewWillAppear(animated)
        onChromeSafariBrowserOpened()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onChromeSafariBrowserClosed()
        self.dispose()
    }
    
    
    func prepareSafariBrowser() {
        guard let safariOptions = safariOptions else {
            return
        }
        
        if #available(iOS 11.0, *) {
            self.dismissButtonStyle = SFSafariViewController.DismissButtonStyle(rawValue: safariOptions.dismissButtonStyle)!
        }
        
        if #available(iOS 10.0, *) {
            if let preferredBarTintColor = safariOptions.preferredBarTintColor, !preferredBarTintColor.isEmpty {
                self.preferredBarTintColor = UIColor(hexString: preferredBarTintColor)
            }
            if let preferredControlTintColor = safariOptions.preferredControlTintColor, !preferredControlTintColor.isEmpty {
                self.preferredControlTintColor = UIColor(hexString: preferredControlTintColor)
            }
        }
        
        self.modalPresentationStyle = UIModalPresentationStyle(rawValue: safariOptions.presentationStyle)!
        self.modalTransitionStyle = UIModalTransitionStyle(rawValue: safariOptions.transitionStyle)!
    }
    
    func close(result: FlutterResult?) {
        dismiss(animated: true)
        
        // wait for the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {() -> Void in
            if result != nil {
               result!(true)
            }
        })
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        close(result: nil)
    }
    
    public func safariViewController(_ controller: SFSafariViewController,
                              didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if didLoadSuccessfully {
            onChromeSafariBrowserCompletedInitialLoad()
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
    
    public func onChromeSafariBrowserOpened() {
        channel?.invokeMethod("onChromeSafariBrowserOpened", arguments: [])
    }
    
    public func onChromeSafariBrowserCompletedInitialLoad() {
        channel?.invokeMethod("onChromeSafariBrowserCompletedInitialLoad", arguments: [])
    }
    
    public func onChromeSafariBrowserClosed() {
        channel?.invokeMethod("onChromeSafariBrowserClosed", arguments: [])
    }
    
    public func dispose() {
        channel?.setMethodCallHandler(nil)
        channel = nil
        delegate = nil
    }
}

class CustomUIActivity : UIActivity {
    var viewId: String
    var id: Int64
    var url: URL
    var title: String?
    var type: UIActivity.ActivityType?
    var label: String?
    var image: UIImage?
    
    init(viewId: String, id: Int64, url: URL, title: String?, label: String?, type: UIActivity.ActivityType?, image: UIImage?) {
        self.viewId = viewId
        self.id = id
        self.url = url
        self.title = title
        self.label = label
        self.type = type
        self.image = image
    }

    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return type
    }

    override var activityTitle: String? {
        return label
    }

    override var activityImage: UIImage? {
        return image
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func perform() {
        guard let registrar = SwiftFlutterPlugin.instance?.registrar else {
            return
        }
        
        let channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_chromesafaribrowser_" + viewId,
                                           binaryMessenger: registrar.messenger())
        
        let arguments: [String: Any?] = [
            "url": url.absoluteString,
            "title": title,
            "id": id,
        ]
        channel.invokeMethod("onChromeSafariBrowserMenuItemActionPerform", arguments: arguments)
    }
}
