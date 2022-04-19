//
//  ContextMenuOptions.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 30/05/2020.
//

import Foundation

class ContextMenuOptions: IWebViewSettings<NSObject> {
    
    var hideDefaultSystemContextMenuItems = false;

    override init(){
        super.init()
    }
}
