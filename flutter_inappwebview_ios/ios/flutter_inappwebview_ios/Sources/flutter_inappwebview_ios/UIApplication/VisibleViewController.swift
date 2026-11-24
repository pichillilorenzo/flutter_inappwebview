//
//  VisibleViewController.swift
//  flutter_inappwebview
//
//  Created by Alexandru Terente on 02.08.2023.
//

import UIKit

extension InAppWebViewFlutterPlugin {
    var window: UIWindow? {
        // Do not select a window from UIApplication.connectedScenes: it may
        // belong to another engine when the host has multiple scenes.
        var controller = registrar.viewController
        while let current = controller {
            if let window = current.viewIfLoaded?.window {
                return window
            }
            // A full-screen presentation can temporarily remove the Flutter
            // view from the window while its presented controller stays there.
            controller = current.presentedViewController
        }
        return nil
    }

    var visibleViewController: UIViewController? {
        guard let rootViewController = window?.rootViewController else {
            return nil
        }
        return getVisibleViewController(rootViewController)
    }

    private func getVisibleViewController(_ controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController, !presented.isBeingDismissed {
            return getVisibleViewController(presented)
        }
        if let navigation = controller as? UINavigationController,
           let visible = navigation.visibleViewController {
            return getVisibleViewController(visible)
        }
        if let tab = controller as? UITabBarController,
           let selected = tab.selectedViewController {
            return getVisibleViewController(selected)
        }
        return controller
    }
}
