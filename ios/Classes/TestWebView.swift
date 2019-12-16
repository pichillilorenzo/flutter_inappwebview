//
//  TestWebView.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 14/12/2019.
//

import Flutter
import Foundation
import WebKit

public class TestWebView: WKWebView {
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public override func removeFromSuperview() {
        configuration.userContentController.removeAllUserScripts()
        super.removeFromSuperview()
        print("\n\n DISPOSE \n\n")
    }
    
    deinit {
        print("dealloc") // never called
    }
}
