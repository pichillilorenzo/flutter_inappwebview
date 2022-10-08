//
//  UIFindSession.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 07/10/22.
//

import Foundation

@available(iOS 16.0, *)
extension UIFindSession {
    public func toMap () -> [String:Any?] {
        return [
            "resultCount": resultCount,
            "highlightedResultIndex": highlightedResultIndex,
            "searchResultDisplayStyle": searchResultDisplayStyle.rawValue
        ]
    }
}
