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
    var uuid: String = ""
    var menuItemList: [[String: Any]] = []
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    deinit {
        print("SafariViewController - dealloc")
    }
    
    public func prepareMethodChannel() {
        channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_chromesafaribrowser_" + uuid, binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
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
        if #available(iOS 11.0, *) {
            self.dismissButtonStyle = SFSafariViewController.DismissButtonStyle(rawValue: (safariOptions?.dismissButtonStyle)!)!
        }
        
        if #available(iOS 10.0, *) {
            if !(safariOptions?.preferredBarTintColor.isEmpty)! {
                self.preferredBarTintColor = color(fromHexString: (safariOptions?.preferredBarTintColor)!)
            }
            if !(safariOptions?.preferredControlTintColor.isEmpty)! {
                self.preferredControlTintColor = color(fromHexString: (safariOptions?.preferredControlTintColor)!)
            }
        }
        
        self.modalPresentationStyle = UIModalPresentationStyle(rawValue: (safariOptions?.presentationStyle)!)!
        self.modalTransitionStyle = UIModalTransitionStyle(rawValue: (safariOptions?.transitionStyle)!)!
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
            let activity = CustomUIActivity(uuid: uuid, id: menuItem["id"] as! Int64, url: URL, title: title, label: menuItem["label"] as? String, type: nil, image: nil)
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
        channel!.invokeMethod("onChromeSafariBrowserOpened", arguments: [])
    }
    
    public func onChromeSafariBrowserCompletedInitialLoad() {
        channel!.invokeMethod("onChromeSafariBrowserCompletedInitialLoad", arguments: [])
    }
    
    public func onChromeSafariBrowserClosed() {
        channel!.invokeMethod("onChromeSafariBrowserClosed", arguments: [])
    }
    
    public func dispose() {
        delegate = nil
        channel!.setMethodCallHandler(nil)
    }
    
    // Helper function to convert hex color string to UIColor
    // Assumes input like "#00FF00" (#RRGGBB).
    // Taken from https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
    func color(fromHexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: fromHexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

class CustomUIActivity : UIActivity {
    var uuid: String
    var id: Int64
    var url: URL
    var title: String?
    var type: UIActivity.ActivityType?
    var label: String?
    var image: UIImage?
    
    init(uuid: String, id: Int64, url: URL, title: String?, label: String?, type: UIActivity.ActivityType?, image: UIImage?) {
        self.uuid = uuid
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
        let channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_chromesafaribrowser_" + uuid, binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        
        let arguments: [String: Any?] = [
            "url": url.absoluteString,
            "title": title,
            "id": id,
        ]
        channel.invokeMethod("onChromeSafariBrowserMenuItemActionPerform", arguments: arguments)
    }
}
