//
//  InAppBrowserNavigationController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 14/02/21.
//

import Foundation
import UIKit

public class InAppBrowserNavigationController: UINavigationController {
    weak var hostWindow: UIWindow?

    deinit {
        debugPrint("InAppBrowserNavigationController - dealloc")
        hostWindow?.makeKeyAndVisible()
    }
}
