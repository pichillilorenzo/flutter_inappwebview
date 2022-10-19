//
//  PrintJobManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 09/05/22.
//

import Foundation

public class PrintJobManager: NSObject, Disposable {
    static var jobs: [String: PrintJobController?] = [:]
    
    public override init() {
        super.init()
    }
    
    public func dispose() {
        let jobs = PrintJobManager.jobs.values
        jobs.forEach { (job: PrintJobController?) in
            job?.dispose()
        }
        PrintJobManager.jobs.removeAll()
    }
    
    deinit {
        dispose()
    }
}
