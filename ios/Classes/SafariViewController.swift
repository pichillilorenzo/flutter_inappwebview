//
//  SafariViewController.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 25/09/18.
//

import Foundation
import SafariServices

@available(iOS 9.0, *)
class SafariViewController: SFSafariViewController, SFSafariViewControllerDelegate {
    
    weak var statusDelegate: SwiftFlutterPlugin?
    var tmpWindow: UIWindow?
    var safariOptions: SafariBrowserOptions?
    var uuid: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        prepareSafariBrowser()
        super.viewWillAppear(animated)
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
    
    func close() {
        dismiss(animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {() -> Void in
            self.tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            
            if (self.statusDelegate != nil) {
                self.statusDelegate?.safariExit(uuid: self.uuid)
            }
        })
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        close()
    }
    
    func safariViewController(_ controller: SFSafariViewController,
                              didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if didLoadSuccessfully {
            statusDelegate?.onChromeSafariBrowserLoaded(uuid: self.uuid)
        }
        else {
            print("Cant load successfully the 'SafariViewController'.")
        }
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
