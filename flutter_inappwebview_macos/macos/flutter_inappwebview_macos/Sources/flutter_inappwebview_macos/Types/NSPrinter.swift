//
//  NSPrinter.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 17/10/22.
//

import Foundation
import AppKit

extension NSPrinter {
    public func toMap () -> [String:Any?] {
        return [
            "type": type.rawValue,
            "languageLevel": languageLevel,
            "name": name
        ]
    }
}
