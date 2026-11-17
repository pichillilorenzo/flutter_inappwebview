//
//  VisibleViewController.swift
//  flutter_inappwebview
//
//  Created by Alexandru Terente on 02.08.2023.
//

import UIKit

extension UIApplication {

    var visibleViewController: UIViewController? {
        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }
        return getVisibleViewController(rootViewController)
    }

    func visibleViewController(presentingFrom rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return visibleViewController
        }
        // A registrar's view can be hidden by a container or a full-screen
        // presentation while its engine still owns the same window. Follow
        // that hierarchy before checking attachment, without selecting another
        // scene through UIApplication's global key window.
        var container = rootViewController
        while let parent = container.parent {
            container = parent
        }
        guard let visibleViewController = getVisibleViewController(container),
              visibleViewController.viewIfLoaded?.window != nil else {
            return nil
        }
        return visibleViewController
    }

    private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController.flatMap(getVisibleViewController)
        }
        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController.flatMap(getVisibleViewController)
        }
        return rootViewController
    }
}
