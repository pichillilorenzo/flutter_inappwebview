//
//  PrintJobInfo.swift
//  flutter_downloader
//
//  Created by Lorenzo Pichilli on 10/05/22.
//

import Foundation

public class PrintJobInfo : NSObject {
    var state: PrintJobState
    var attributes: PrintAttributes
    var creationTime: Int64
    var numberOfPages: Int?
    var copies: Int?
    var label: String?
    var printerName: String?
    var printerType: String?
    
    public init(fromPrintJobController: PrintJobController) {
        state = fromPrintJobController.state
        creationTime = fromPrintJobController.creationTime
        attributes = PrintAttributes.init(fromPrintJobController: fromPrintJobController)
        if let job = fromPrintJobController.job {
            let printInfo = job.printInfo
            printerName = printInfo.printer.name
            printerType = printInfo.printer.type.rawValue
            copies = printInfo.printSettings["com_apple_print_PrintSettings_PMCopies"] as? Int
        }
        super.init()
        if let job = fromPrintJobController.job {
            let printInfo = job.printInfo
            label = job.jobTitle
            numberOfPages = printInfo.printSettings["com_apple_print_PrintSettings_PMLastPage"] as? Int
            if numberOfPages == nil || numberOfPages! > job.pageRange.length {
                numberOfPages = job.pageRange.length
            }
        }
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "state": state.rawValue,
            "attributes": attributes.toMap(),
            "numberOfPages": numberOfPages,
            "copies": copies,
            "creationTime": creationTime,
            "label": label,
            "printerName": printerName,
            "printerType": printerType
        ]
    }
}
