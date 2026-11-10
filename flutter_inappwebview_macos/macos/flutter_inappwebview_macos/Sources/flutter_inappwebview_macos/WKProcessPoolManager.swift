//
//  WKProcessPoolManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/11/2019.
//

import Foundation
import WebKit

@available(macOS, deprecated: 12.0, message: "WKProcessPool has no effect from macOS 12.")
public class WKProcessPoolManager {
    static let sharedProcessPool = WKProcessPool()
}
