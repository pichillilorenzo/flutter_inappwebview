//
//  LeakAvoider.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 15/12/2019.
//

import Foundation

public class LeakAvoider: NSObject {
    weak var delegate : FlutterMethodCallDelegate?
    
    init(delegate: FlutterMethodCallDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.delegate?.handle(call, result: result)
    }
    
    deinit {
        print("LeakAvoider - dealloc")
    }
}
