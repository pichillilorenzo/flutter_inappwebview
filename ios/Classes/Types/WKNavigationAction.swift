//
//  WKNavigationAction.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation
import WebKit

extension WKNavigationAction {
    public func toMap () -> [String:Any?] {
        return [
            "request": request.toMap(),
            "isForMainFrame": targetFrame?.isMainFrame ?? false,
            "iosWKNavigationType": navigationType.rawValue,
            "iosSourceFrame": sourceFrame.toMap(),
            "iosTargetFrame": targetFrame?.toMap()
        ]
    }
}
