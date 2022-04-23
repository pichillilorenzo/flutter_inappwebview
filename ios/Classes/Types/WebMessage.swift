//
//  WebMessage.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/03/21.
//

import Foundation

public class WebMessage : NSObject {
    var data: String?
    var ports: [WebMessagePort]?
    
    public init(data: String?, ports: [WebMessagePort]?) {
        super.init()
        self.data = data
        self.ports = ports
    }
    
    public func dispose() {
        ports?.removeAll()
    }
    
    deinit {
        print("WebMessage - dealloc")
        dispose()
    }
}
