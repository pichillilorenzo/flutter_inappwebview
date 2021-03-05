//
//  PullToRefreshOptions.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 03/03/21.
//

import Foundation

public class PullToRefreshOptions : Options<PullToRefreshControl> {
    
    var enabled = true
    var color: String?
    var backgroundColor: String?
    var attributedTitle: [String: Any?]?
    
    override init(){
        super.init()
    }
    
    override func parse(options: [String: Any?]) -> PullToRefreshOptions {
        let _ = super.parse(options: options)
        if let attributedTitle = options["attributedTitle"] as? [String: Any?] {
            self.attributedTitle = attributedTitle
        }
        return self
    }
    
    override func getRealOptions(obj: PullToRefreshControl?) -> [String: Any?] {
        let realOptions: [String: Any?] = toMap()
        return realOptions
    }
}
